# MindMentor Architecture

Welcome to the MindMentor codebase. This document maps out the architecture, data flow, and key integration points to ensure consistent development.

## 📁 Directory Structure

```text
MindMentor/
├── lib/
│   ├── main.dart                 # App entry point, Sentry init, Theme configuration
│   ├── core/                     # Foundational architecture
│   │   ├── models/               # Immutable data models (MoodLog, ChatMessage)
│   │   ├── providers/            # Global providers (AuthNotifier, ErrorReporter, Supabase)
│   │   ├── routing/              # GoRouter configuration & guards
│   │   └── theme/                # AppTheme, AppColors (Light/Dark mode)
│   ├── features/                 # Feature-based modular structure
│   │   ├── auth/                 # Login & Registration screens
│   │   ├── chat/                 # AI Chat UI, Crisis Protocol, ChatNotifier
│   │   ├── emergency/            # 988 Lifeline resources screen
│   │   ├── insights/             # Monthly mood calendar and trends
│   │   ├── mood/                 # Home screen and MoodLogsNotifier
│   │   └── onboarding/           # First-time user 3-slide flow
│   └── shared/                   # Reusable UI components
│       └── widgets/              # GlassCard, PillButton, AppShell (Bottom Nav)
├── supabase/
│   ├── functions/                # Edge Functions
│   │   └── ai_proxy/             # Deno proxy for OpenRouter API
│   └── migrations/               # PostgreSQL schema & RLS policies
└── test/                         # Unit and Widget tests
    ├── helpers/                  # test_helpers.dart (Mock definitions & Riverpod overrides)
    ├── core/models/              # Serialization tests
    ├── features/                 # Provider logic tests (ChatNotifier, Crisis Protocol)
    └── shared/widgets/           # Component rendering tests (PillButton, etc.)
```

## 🔄 Data Flow Diagram: Chat Message Lifecycle

The chat feature uses an optimistic UI update pattern combined with Edge Function persistence.

1. **User Input & Crisis Check**: User types a message. `ChatScreen` intercepts the input and checks against crisis keywords. If detected, it locks the chat and routes to `/emergency`.
2. **Optimistic UI Update**: If safe, `ChatNotifier.sendMessage()` creates a local `ChatMessage` and immediately adds it to the UI state.
3. **Edge Function Invocation**: The client calls `Supabase.functions.invoke('ai_proxy')`, passing the message history and session ID. The Supabase SDK automatically attaches the user's JWT.
4. **Backend Processing (Deno proxy)**: 
   - Verifies the user's JWT.
   - Saves the user's message to the `messages` table in PostgreSQL.
   - Forwards the conversation to OpenRouter/Claude 3 Haiku.
   - Receives the AI response and saves it to the `messages` table.
5. **UI Sync**: The Edge Function returns the AI response to the Flutter client. `ChatNotifier` parses the response and updates the UI state with the AI's `ChatMessage`.

## 🔐 Authentication Flow

MindMentor uses a reactive routing architecture to ensure unauthenticated users cannot access protected screens.

1. **Supabase Auth Stream**: `Supabase.instance.client.auth.onAuthStateChange` emits events when the user signs in, signs out, or their token refreshes.
2. **AuthNotifier**: Listens to this stream and updates the global `AppAuthState`.
3. **GoRouterRefreshStream**: A bridge class that converts the Supabase auth stream into a `ChangeNotifier`.
4. **Router Guards**: `GoRouter`'s `refreshListenable` property is bound to the `GoRouterRefreshStream`. Whenever auth state changes, GoRouter re-evaluates its `redirect` logic:
   - Evaluates if the user has completed onboarding (via `flutter_secure_storage`).
   - If not authenticated, redirects to `/login`.
   - If authenticated but on a public route (`/login`, `/register`), redirects to `/` (Home).
   - `/emergency` is an exception and remains globally accessible at all times.

## 🧪 Testing Strategy & Safety Assurance

The project employs a strict, automated QA layer to guarantee safety and rendering stability.

1. **Mocking Engine**: 
   - All tests isolate the UI and business logic from external dependencies (Supabase, GoRouter, API services) using the `mocktail` package. 
   - The UI is deeply decoupled from implementation specifics via Riverpod, allowing seamless injection of `MockChatNotifier` and other mocked dependencies during widget tests.
   
2. **Crisis Intervention Protocol (Mathematical Proof)**: 
   - **Unit Tests**: Explicitly verify the string-parsing logic in `ChatNotifier.containsCrisisKeyword()` against exact matches and false positives.
   - **Widget Tests**: Assert that triggering the crisis path explicitly calls GoRouter's redirect to `/emergency` before any Edge Function invocation occurs. This forms a mathematically reliable safety boundary preventing unsafe operations during critical mental health events.
