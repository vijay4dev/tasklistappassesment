# Mini TaskHub — Setup Guide

Phase-wise instructions to run this Flutter + Supabase app locally.

**Tech used**
- Flutter (UI)
- Supabase (Auth + PostgreSQL + auto REST)
- Provider (state management)
- flutter_dotenv (env config)

---

## Phase 1 — Prerequisites
- Install Flutter SDK and set up Android/iOS tooling
- Create a free Supabase account at https://supabase.com
- Have a modern Node/Java/Android toolchain for emulator/device testing (as per Flutter docs)

---

## Phase 2 — Supabase Setup

Supabase is an open-source Firebase alternative that provides:
- Authentication (email/password login)
- PostgreSQL Database (to store tasks)
- Auto-generated REST API (used via Supabase Flutter SDK)

### Step 2.1 — Supabase Account + Project
1. Go to supabase.com → Sign Up (free)
2. Click “New Project”
3. Fill details:
   - Project name: `whatever_you_like`
   - Database password: choose a strong password (save it!)
   - Region: pick one near you (e.g., “Asia South = Singapore”)
4. Click “Create new project” and wait ~2 minutes

### Step 2.2 — Create Tasks Table
Left sidebar → “SQL Editor”. Open a new query window and run:

```sql
-- Tasks table banao
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  priority TEXT NOT NULL DEFAULT 'medium',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  category TEXT
);
```

Column overview:
- id (UUID): Unique identifier, auto-generated
- user_id (UUID): Which user owns the task (foreign key to auth.users)
- title (TEXT): Task name
- description (TEXT): Optional details
- status (TEXT): `'pending' | 'completed'`
- priority (TEXT): `'low' | 'medium' | 'high'`
- created_at (TIMESTAMPTZ): Created timestamp (with timezone)
- completed_at (TIMESTAMPTZ): Completion time (null if pending)
- category (TEXT): e.g., Work, Personal

Why `ON DELETE CASCADE`?
- If a user deletes their account, all their tasks are automatically removed — no orphaned data.

### Step 2.3 — Enable Row Level Security (RLS)
Run this in SQL Editor:

```sql
-- RLS enable karo (by default OFF hota hai)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Policy: Sirf apne tasks dekh/edit/delete kar sako
CREATE POLICY "Users manage their own tasks"
  ON tasks
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

RLS is MUST:
- Without RLS, anyone who guesses a user ID could read/delete their tasks via API calls.  
- RLS ensures `auth.uid()` (logged-in user ID) must match `user_id` for all operations.

### Step 2.4 — Copy API Keys
Left sidebar → Settings → API. Copy:
- Project URL: `https://xxxxxxxxxxx.supabase.co`
- anon public key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

We’ll use these in the Flutter app via `.env`.

---

## Phase 3 — Flutter App Setup

### 3.1 Clone and install dependencies
```bash
git clone <this-repo>
cd tasklistapp
flutter pub get
```

### 3.2 Configure environment variables
Create a file named `.env` at the project root:

```
project_url=https://YOUR-PROJECT-ID.supabase.co
anon_key=YOUR-ANON-PUBLIC-KEY
```

This app already includes `.env` in `pubspec.yaml` assets and loads it in `main.dart`:
- `Supabase.initialize(url: dotenv.env['project_url'], anonKey: dotenv.env['anon_key'])`

Security tip:
- Do NOT commit real keys. Keep `.env` private. Rotate keys if leaked.

### 3.3 Run the app
```bash
flutter run
```

Sign up with email/password, then sign in. Your name is saved as `full_name` in Supabase user metadata and shown in the dashboard header.

---

## Phase 4 — Features Overview
- Email/password authentication via Supabase
- Tasks CRUD:
  - Add, edit, delete tasks
  - Toggle complete/pending
  - Priority and optional category/description
- Filtering and progress:
  - Filter chips (All/Pending/Completed) with selected underline
  - Progress stats and indicators using completion rate
- Responsive and animated UI with Provider-driven state

---

## Phase 5 — Troubleshooting
- Blank screen after launch:
  - Check `.env` values and internet connectivity
  - Ensure the Supabase project is created and RLS policies exist
- Can’t see your name:
  - The app reads `user.userMetadata['full_name']`; ensure you signed up with a name
  - Falls back to the email’s local-part if `full_name` is missing
- “Failed to add/update task”:
  - Verify Supabase keys and RLS policy; ensure you are authenticated

---

## Phase 6 — Useful Files
- App entry and Supabase init: `lib/main.dart`
- Auth service: `lib/auth/auth_services.dart`
- Tasks provider: `lib/dashboard/task_provider.dart`
- Add Task sheet: `lib/dashboard/task_add_sheet.dart`
- Dashboard UI: `lib/dashboard/dashboard_screen.dart`
- Common widgets: `lib/widgets/commonwidgets.dart`
