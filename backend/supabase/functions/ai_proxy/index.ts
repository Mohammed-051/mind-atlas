// ==========================================================================
// MindMentor AI Proxy — Supabase Deno Edge Function
// Securely proxies chat requests to OpenRouter (Claude 3 Haiku)
// ==========================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const OPENROUTER_API_KEY = Deno.env.get("OPENROUTER_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const SYSTEM_PROMPT = `You are MindMentor, a warm, compassionate AI companion dedicated to supporting mental well-being. Your role is to:

1. VALIDATE emotions — acknowledge and normalize what the user is feeling.
2. LISTEN actively — reflect back what you hear, ask gentle clarifying questions.
3. SUGGEST coping strategies — breathing exercises, grounding techniques, journaling prompts, and mindfulness practices.
4. ENCOURAGE professional help — gently recommend speaking with a licensed therapist when appropriate.

STRICT MEDICAL CONSTRAINTS:
- You must NEVER offer medical diagnoses of any kind.
- You must NEVER prescribe, recommend, or suggest specific medications.
- You must NEVER claim to be a therapist, doctor, or medical professional.
- You must NEVER minimize or dismiss the user's feelings.

If a user expresses thoughts of self-harm or suicide, respond with:
"I hear you, and I'm glad you shared that with me. Please reach out to the 988 Suicide & Crisis Lifeline by calling or texting 988. You deserve immediate, professional support."

Keep your tone warm, gentle, and non-judgmental. Use simple language. End responses with a supportive affirmation or gentle question to keep the conversation flowing.`;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ------------------------------------------------------------------
    // 1. Extract & verify the Supabase JWT
    // ------------------------------------------------------------------
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Missing or invalid authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: `Bearer ${token}` } },
    });

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: invalid token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ------------------------------------------------------------------
    // 2. Parse the request body
    // ------------------------------------------------------------------
    const { messages, sessionId } = await req.json();

    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return new Response(
        JSON.stringify({ error: "Messages array is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ------------------------------------------------------------------
    // 3. Build the OpenRouter payload with system prompt injection
    // ------------------------------------------------------------------
    const openRouterMessages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...messages.map((m: { role: string; content: string }) => ({
        role: m.role,
        content: m.content,
      })),
    ];

    // ------------------------------------------------------------------
    // 4. Call OpenRouter API
    // ------------------------------------------------------------------
    const openRouterResponse = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "https://mindmentor.app",
          "X-Title": "MindMentor",
        },
        body: JSON.stringify({
          model: "anthropic/claude-3-haiku",
          messages: openRouterMessages,
          max_tokens: 1024,
          temperature: 0.7,
          top_p: 0.9,
        }),
      }
    );

    if (!openRouterResponse.ok) {
      const errorText = await openRouterResponse.text();
      console.error("OpenRouter error:", errorText);
      return new Response(
        JSON.stringify({ error: "AI service temporarily unavailable" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const completion = await openRouterResponse.json();
    const assistantMessage =
      completion.choices?.[0]?.message?.content ?? "I'm here for you. Could you tell me more?";

    // ------------------------------------------------------------------
    // 5. Persist messages to the database
    // ------------------------------------------------------------------
    if (sessionId) {
      const userMessage = messages[messages.length - 1];

      await supabase.from("messages").insert([
        {
          session_id: sessionId,
          user_id: user.id,
          role: "user",
          content: userMessage.content,
        },
        {
          session_id: sessionId,
          user_id: user.id,
          role: "assistant",
          content: assistantMessage,
        },
      ]);
    }

    // ------------------------------------------------------------------
    // 6. Return the AI response
    // ------------------------------------------------------------------
    return new Response(
      JSON.stringify({
        message: assistantMessage,
        sessionId: sessionId,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
