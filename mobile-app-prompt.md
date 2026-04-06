# Ajiriwa Mobile App – Production-Ready Flutter Prompt

## Objective
Design and implement a well-structured, polished, production-quality Flutter mobile app (Android and iOS) for Ajiriwa that focuses on the candidate experience. The app must faithfully reflect the elegance and brand of the web platform and enable candidates to log in and use all core features from mobile. All data comes from the Ajiriwa API hosted under https://www.ajiriwa.net.

## Branding and Visual Direction
- Primary color: Emerald Green (#10B981) with dark variant (#059669)
- Neutrals: White (#FFFFFF), Slate/Gray (#6B7280, #374151)
- Typography: System default (SF Pro on iOS, Roboto on Android) with consistent type scale
- Shapes: Rounded corners (8dp), subtle elevation, soft shadows, generous white space
- Layout: Spacious cards, high contrast on CTAs, consistent 8dp spacing grid
- Imagery: Simple, professional, restrained use of illustrations/icons (feather or material icons)

## App Architecture and Tech Choices
- State management: BLoC/Cubit
- Data: Repository + Data Source (Remote via REST) + Model (immutable, json_serializable)
- Auth: Token-based (Laravel Sanctum compatible) stored securely via flutter_secure_storage
- Navigation: GoRouter with named routes; bottom navigation tabs
- Theming: Light theme first; dark mode optional
- Networking: Dio or http + interceptors for auth headers, logging in debug
- Persistence: Hive or shared_preferences for lightweight caching; secure storage for tokens
- Analytics/Crash: Firebase Analytics + Crashlytics (optional)
- Testing: Unit tests for repositories/BLoCs, widget tests for screens, golden tests for core UI

## App Navigation and Screens (map to web routes)
Bottom tabs: Dashboard, Jobs, Applications, Saved, Profile. Auth screens accessible when logged out. Additional flows push on top.

1) /dashboard → Mobile: DashboardScreen
- Shows: Greeting, profile completion, quick actions, recommended jobs, recent applications, notifications badge.
- API:
  - GET https://www.ajiriwa.net/api/v1/profile (auth)
  - GET https://www.ajiriwa.net/api/v1/jobs/recommended (auth)
  - GET https://www.ajiriwa.net/api/v1/applications (auth)
  - GET https://www.ajiriwa.net/api/v1/notifications (auth)

2) /browse/jobs → Mobile: JobsBrowseScreen
- Shows: Search bar, filters (category, type, location, salary), paginated list.
- API:
  - GET https://www.ajiriwa.net/api/v1/jobs?query=&category=&type=&location=&min_salary=&page=
  - GET https://www.ajiriwa.net/api/v1/job-categories
  - GET https://www.ajiriwa.net/api/v1/job-types
  - GET https://www.ajiriwa.net/api/v1/jobs/{id}

3) /my-resume → Mobile: MyResumeScreen (read-only summary)
- Shows: Personal info, summary, education, experience, skills, certifications, references, attachments.
- API:
  - GET https://www.ajiriwa.net/api/v1/profile (auth)
  - GET https://www.ajiriwa.net/api/v1/education (auth)
  - GET https://www.ajiriwa.net/api/v1/experience (auth)
  - GET https://www.ajiriwa.net/api/v1/skills (auth)

4) /my-resume/edit → Mobile: EditResumeScreen (tabbed editing)
- Tabs: Personal, Summary, Education (CRUD), Experience (CRUD), Skills (CRUD), Certifications (if exposed), References (future).
- API (CRUD):
  - PUT https://www.ajiriwa.net/api/v1/profile (auth)
  - POST/PUT/DELETE https://www.ajiriwa.net/api/v1/education[/{id}] (auth)
  - POST/PUT/DELETE https://www.ajiriwa.net/api/v1/experience[/{id}] (auth)
  - POST/PUT/DELETE https://www.ajiriwa.net/api/v1/skills[/{id}] (auth)
  - POST https://www.ajiriwa.net/api/v1/profile/photo (auth, multipart)

5) /my-applications → Mobile: ApplicationsScreen
- Shows: List with status badges, dates, job titles; detail view; withdraw if supported.
- API:
  - GET https://www.ajiriwa.net/api/v1/applications (auth)
  - GET https://www.ajiriwa.net/api/v1/applications/{id} (auth)
  - POST https://www.ajiriwa.net/api/v1/jobs/{jobId}/apply (auth) [Submission]
  - [Optional] POST https://www.ajiriwa.net/api/v1/applications/{id}/withdraw (auth) — if not available, see gaps below

6) /save-jobs → Mobile: SavedJobsScreen
- Shows: Saved jobs list with unsave action.
- API:
  - GET https://www.ajiriwa.net/api/v1/jobs/saved (auth)
  - POST https://www.ajiriwa.net/api/v1/jobs/{id}/save (auth)
  - DELETE https://www.ajiriwa.net/api/v1/jobs/{id}/save (auth)

7) /auto-apply → Mobile: AutoApplyScreen
- Shows: Auto-apply status, configuration (keywords, locations, frequency), enable/disable, activity log.
- Current API gap: No explicit endpoints in summary. Propose the following (to be implemented or confirmed):
  - GET https://www.ajiriwa.net/api/v1/auto-apply/status (auth)
  - PUT https://www.ajiriwa.net/api/v1/auto-apply/settings (auth)
  - POST https://www.ajiriwa.net/api/v1/auto-apply/toggle (auth)
  - GET https://www.ajiriwa.net/api/v1/auto-apply/logs?page= (auth)

8) /login → Mobile: LoginScreen
- Email/password with optional biometric unlock after first login. Lets also integrate login with google and apple.
- API:
  - POST https://www.ajiriwa.net/api/v1/auth/login {email, password}
  - POST https://www.ajiriwa.net/api/v1/auth/logout (auth)

9) /register → Mobile: RegisterScreen
- Email, name, password, confirm; verify email flow; optional phone.
- API:
  - POST https://www.ajiriwa.net/api/v1/auth/register
  - POST https://www.ajiriwa.net/api/v1/auth/email/verification-notification (auth)
  - POST https://www.ajiriwa.net/api/v1/auth/email/verify/{id}/{hash}
  - POST https://www.ajiriwa.net/api/v1/auth/forgot-password
  - POST https://www.ajiriwa.net/api/v1/auth/reset-password

## Authentication and Session Handling
- On successful login, store access token securely (flutter_secure_storage). Add Authorization: Bearer <token> header to all protected requests.
- Use an AuthInterceptor to inject token and handle 401 by refreshing state and redirecting to LoginScreen.
- Persist minimal profile snapshot for fast Dashboard skeleton.
- Optional: biometric quick unlock to reveal stored token; fall back to password if biometric fails.

## API Interaction Details and Examples
Base URL: https://www.ajiriwa.net/api/v1
Headers (JSON):
- Content-Type: application/json
- Accept: application/json
- Authorization: Bearer <token> (when authenticated)

Examples
1) Login
curl -X POST https://www.ajiriwa.net/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
Response 200: {"token":"<jwt_or_sanctum_token>","user":{"id":1,"name":"..."}}

2) List Jobs
curl "https://www.ajiriwa.net/api/v1/jobs?query=developer&location=Dar&page=1"
Response 200: {"data":[{"id":123,"title":"...","company":"...","location":"..."}],"meta":{"page":1,"has_more":true}}

3) Save a Job
curl -X POST https://www.ajiriwa.net/api/v1/jobs/123/save \
  -H "Authorization: Bearer <token>"

4) Apply to a Job
curl -X POST https://www.ajiriwa.net/api/v1/jobs/123/apply \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"cover_letter":"...","answers":[{"question_id":1,"answer":"Yes"}]}'

5) Update Profile
curl -X PUT https://www.ajiriwa.net/api/v1/profile \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","headline":"Software Engineer"}'

6) Upload Profile Photo (multipart)
POST https://www.ajiriwa.net/api/v1/profile/photo
- Headers: Authorization: Bearer <token>
- Body: multipart/form-data; file=@/path/me.jpg; field name: photo

7) Proposed Auto-Apply (until confirmed)
- GET /auto-apply/status → {"enabled":true,"settings":{"keywords":["flutter"],"locations":["Dar es Salaam"],"frequency":"daily"}}
- PUT /auto-apply/settings {"keywords":[],"locations":[],"frequency":"daily|weekly","apply_limit":N}
- POST /auto-apply/toggle {"enabled":true}
- GET /auto-apply/logs?page= → {"data":[{"id":1,"job_id":123,"status":"applied","timestamp":"..."}]}

## UX and Interaction Patterns
- Use skeleton loaders for first paint; show shimmer on lists.
- Optimistic UI for save/unsave job with rollback on failure.
- Pull-to-refresh on all list screens.
- Infinite scroll with paginated endpoints (page param).
- Error surfaces: inline error banners; retry CTA.
- Empty states with guidance (e.g., no applications yet → browse jobs CTA).
- Accessibility: 44dp touch targets, sufficient color contrast, scalable fonts.

## Performance Considerations
- Debounce search input (300–500ms) before calling /jobs.
- Cache filters, categories, and types locally with TTL.
- Preload dashboard requests in parallel.
- Use thumbnails and cached_network_image for logos.

## Security
- Securely store token; never log tokens in production.
- Validate all API inputs client-side; display server messages safely.
- Handle 401/403 with clear actions; purge sensitive data on logout.

## Testing Checklist
- Auth flow (login/register/verify/logout)
- Resume CRUD (education/experience/skills)
- Jobs browse/search/pagination/details
- Save/unsave job; apply flow with screening
- Applications list/detail; statuses
- Notifications fetch; mark as read
- Auto-apply settings (when endpoints available)
- Offline retry; error states; empty states

## Deliverables
- Flutter app with the screens above using BLoC and clean architecture
- Theming consistent with Ajiriwa brand
- Well-documented repositories and models
- Tests for critical flows
- CI-ready project (format, analyze, tests)

## Known Endpoint Coverage and Gaps
Covered by existing docs (see repo api_endpoints_summary.md): auth, profile, education, experience, skills, jobs (list/detail/recommended), saved jobs, applications, notifications, support messaging. Gaps to implement/confirm for mobile parity:
- Auto-Apply endpoints (status/settings/toggle/logs)
- Applications withdrawal endpoint (applications/{id}/withdraw) if the business flow requires it
- Utility lists (countries/industries/career-levels) if needed for profile forms

Action: If endpoints above are not present in /routes/api.php, add them on backend; this prompt already specifies request/response contracts for swift implementation and frontend integration.
