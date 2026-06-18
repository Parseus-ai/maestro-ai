# 3. Configuration

[← Installation](02-installation.md) · [Next: Running the System →](04-running.md)

---

This page covers everything you configure: your Google Cloud project, the database's `config` tab (your personal settings and AI model choices), and the AI provider credentials.

## Google Cloud setup

This expands on Step 3 of the [Installation Guide](02-installation.md#step-3-set-up-your-google-cloud-project). Maestro reads and writes Google Sheets and stores files in Google Drive on your behalf, using a **service account**, a non-human Google identity with its own key.

### Create the project and enable APIs

1. Open **https://console.cloud.google.com** and sign in.
2. Top bar → project dropdown → **New Project**. Name it `maestro`. Create and select it.
3. Enable these APIs one at a time (search each by name in the top search bar, open it, click **Enable**):
   - **Google Sheets API**, read/write the database
   - **Google Drive API**, store resume/cover-letter files and folders
   - **Google Docs API**, apply formatting to converted documents

### Create the service account and key

1. **APIs & Services → Credentials → Create Credentials → Service account.**
2. Name it `maestro-pipeline`. Click **Create and Continue**, then **Done** (skip the optional role and access steps).
3. Click the service account you just made → **Keys** tab → **Add Key → Create new key → JSON → Create.**
4. A `.json` file downloads. **This is a secret, treat it like a password.** Don't put it in a public folder or commit it to Git.

### Values you'll extract from the JSON

Open the downloaded JSON in a text editor. Two fields matter:

| JSON field | Used as | Where |
|-----------|---------|-------|
| `client_email` | `GOOGLE_SHEETS_CLIENT_EMAIL` | the `.env` file; also shared into the Sheet & Drive folder |
| `private_key` | `GOOGLE_SHEETS_PRIVATE_KEY` | the `.env` file (and the n8n Google credential) |

> ⚠️ **The single-service-account rule.** Both the dashboard and the n8n pipeline must authenticate as the **same** service account. The pipeline creates the Drive folders; the dashboard writes files into them. If they're different accounts, the dashboard can't write to the pipeline's folders and you'll get **403 Forbidden** errors on "Save to Drive."

### Share access

The service account can't see anything until you share it in:

- **The database Sheet**, open it → **Share** → paste `client_email` → **Editor**.
- **The Drive root folder**, create a folder for Maestro's output, share it with `client_email` as **Editor**, and use its ID as `ROOT_FOLDER_ID` in the backend `.env`.

---

## The `config` tab

All of your personal settings live in the `config` tab of the database Sheet. Each row is one setting. The columns are:

| Column | Meaning |
|--------|---------|
| `category` | Grouping (e.g. "Applicant Identity", "LLM - Resume Drafter") |
| `parameter` | The setting's name (this is the key the software reads) |
| `value` | **What you set** |
| `description` | What it does |
| `examples_or_notes` | Hints |
| `display_order`, `input_type`, `options` | Used by the dashboard to render the settings nicely |

You edit the **`value`** column. Below are the settings that matter most.

### Your identity

These appear on your resume header.

| Parameter | Example |
|-----------|---------|
| `applicant_first_name` | `Jane` |
| `applicant_last_name` | `Doe` |
| `applicant_credentials` | `PhD` (optional) |
| `applicant_email` | `jane.applications@gmail.com` |
| `applicant_phone` | `(555) 123-4567` |
| `applicant_location` | `Seattle, WA` |
| `applicant_linkedin_url` | `https://linkedin.com/in/jane-doe` |

> 💡 Many people use a dedicated email for job applications. Set whatever address you want on the resume here.

### What you're targeting

These drive **target fit** scoring and discovery.

| Parameter | Example |
|-----------|---------|
| `target_titles` | `Senior Product Manager, Director of Product` |
| `target_location` | `Seattle, WA` |
| `target_country` | `USA` |
| `domain_interests` | `robotics, autonomous systems, saas` |
| `employment_type_considered` | `full_time` |

### Your background (for background-fit scoring)

| Parameter | Example |
|-----------|---------|
| `background_titles` | `VP Product, Head of AI` |
| `profile_summary` | A short paragraph describing your career identity |

> 📌 **Keep target and background separate.** `target_*` describes the role you *want*; `profile_summary` / `background_titles` describe what you *have*. Mixing them collapses the two fit scores into one. (This was a real bug the project fixed, see [Architecture](05-architecture.md#the-two-scoring-axes).)

### The master document

Your full career history feeds every resume draft. It lives in the `master_doc` tab as `key`/`value` rows (the dashboard's Master Doc page edits it). Think of it as your "everything" resume, the agents pull only the relevant parts per job and are forbidden from inventing anything not in it.

### Pipeline controls

| Parameter | Values | Effect |
|-----------|--------|--------|
| `enable_refinement` | `TRUE` / `FALSE` | Whether Agent 6 refines the resume after the critic |
| `enable_cover_letter` | `TRUE` / `FALSE` | Whether cover letters are generated |
| `discovery_max_jobs_per_run` | a number | How many top jobs get fully scored per discovery run |
| `discovery_rank_title_hard_floor` | a number (e.g. `25`) | Minimum rank score to survive the first-pass ranker |
| `job_search_cron` | a cron expression | Present in the template; the current stack triggers discovery manually and does not read this key |
| `timezone` | e.g. `America/Los_Angeles` | Present in the template, alongside `job_search_cron`; not read by the current stack |

> 💡 Discovery is triggered manually, from the dashboard's Discovery run button or by running **Job Discovery** in n8n. You will see `job_search_cron` and `timezone` in the database template, but the current stack has no scheduler that reads them.

### Choosing AI models per agent

Every agent has three config keys: which provider, which model, and a max-token cap. You can use different providers for different agents (e.g. a cheap model for drafting, a stronger one for refining).

| Agent | Provider key | Model key | Max-tokens key |
|-------|-------------|-----------|----------------|
| 1. Resume Builder | `provider_resume_drafter` | `model_resume_drafter` | `max_tokens_resume_drafter` |
| 2. Cover Letter | `provider_cover_letter_drafter` | `model_cover_letter_drafter` | `max_tokens_cover_letter_drafter` |
| 3. Resume Verifier | `provider_resume_verifier` | `model_resume_verifier` | `max_tokens_resume_verifier` |
| 4. Cover Letter Verifier | `provider_cover_letter_verifier` | `model_cover_letter_verifier` | `max_tokens_cover_letter_verifier` |
| 5. Critic | `provider_critic` | `model_critic` | `max_tokens_critic` |
| 6. Refiner | `provider_refiner` | `model_refiner` | `max_tokens_refiner` |
| 7. Resume Scorer | `provider_resume_scorer` | `model_resume_scorer` | `max_tokens_resume_scorer` |
| 8. Discovery Scorer | `provider_discovery_scorer` | `model_discovery_scorer` | `max_tokens_discovery_scorer` |
| 10. Job Ranker | `provider_discovery_ranker` | `model_discovery_ranker` | `max_tokens_discovery_ranker` |

- **Provider** is one of `anthropic`, `openai`, or `gemini`.
- **Model** must be a valid model name for that provider **and** must exist as a row in the `pricing` tab (so cost can be calculated).

> ⚠️ **No silent fallbacks.** Maestro deliberately has no default model. If a provider/model key is missing or blank, the agent throws an error rather than quietly using something you didn't choose (and didn't budget for). This is intentional, it prevents surprise charges.

### Recommended starting models

A sensible cost/quality balance:

- **Drafting, verifying, scoring, critic, discovery (Agents 1–5, 7, 8):** a fast, cheap model (e.g. Anthropic's Haiku tier).
- **Refining (Agents 6, 9) and ranking (Agent 10):** a stronger model (e.g. a Sonnet tier), since these benefit most from reasoning quality.

Make sure every model you choose has a matching row in the `pricing` tab with its per-million-token input/output rates.

---

## AI provider credentials

Inside n8n, the agents reach the providers through the **Call LLM** sub-workflow, which uses **Header Auth** credentials on its HTTP nodes.

### Anthropic

- **Credentials → Add Credential → Header Auth**
- Header name: `x-api-key`
- Value: your `sk-ant-...` key
- Assign it to the **Anthropic HTTP Request** node in Call LLM.

### OpenAI (optional)

- Header name: `Authorization`
- Value: `Bearer sk-...`
- Assign to the **OpenAI HTTP Request** node.

### Gemini (optional)

- Header name: `x-goog-api-key`
- Value: your Gemini API key
- Assign to the **Gemini HTTP Request** node.

You only need credentials for the providers you actually use in your `config`.

---

## Environment variables reference

Maestro is configured by a single `.env` file at the repo root, copied from `.env.example` and read by the whole stack (n8n and the dashboard).

| Variable | What it is | Default / note |
|----------|-----------|----------------|
| `DASHBOARD_PORT` | Host port for the dashboard | `4400` |
| `GENERIC_TIMEZONE` | IANA timezone for n8n scheduling and logs | `America/Los_Angeles` |
| `N8N_BASIC_AUTH_USER` | Login user for the n8n UI | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Login password for the n8n UI | set your own |
| `ROOT_FOLDER_ID` | Google Drive folder where the pipeline creates per-job folders | required |
| `GOOGLE_SHEETS_CLIENT_EMAIL` | Service account email | required |
| `GOOGLE_SHEETS_PRIVATE_KEY` | Service account private key (one line, literal `\n`) | unescaped at runtime |
| `GOOGLE_SHEETS_DATABASE_ID` | The database Sheet's ID (from its URL) | required |
| `GOOGLE_OAUTH_CLIENT_ID` | OAuth client ID for Drive uploads (Step 3) | required |
| `GOOGLE_OAUTH_CLIENT_SECRET` | OAuth client secret | server-side only |
| `GOOGLE_OAUTH_REFRESH_TOKEN` | OAuth refresh token from the Playground | server-side only |
| `GOOGLE_RESUMES_PARENT_ID` | Drive folder to save resumes and cover letters into | blank uses Drive root |
| `N8N_WEBHOOK_BASE_URL` | Base URL the dashboard calls to trigger the pipeline | `http://n8n:5678/webhook` |
| `MAESTRO_WEBHOOK_SECRET` | Shared secret sent as the `X-Maestro-Secret` header on every webhook call | required |

> ⚠️ Use the production webhook path. `N8N_WEBHOOK_BASE_URL` must end in `/webhook`, not `/webhook-test`. The `-test` path only works while the n8n editor is open with the workflow in listen mode.

> 🔑 The webhook secret is required for triggering. If `MAESTRO_WEBHOOK_SECRET` is blank, the dashboard's trigger routes return 503. Set the same value here and in n8n's webhook Header Auth (header name `X-Maestro-Secret`). See [AI provider credentials](#ai-provider-credentials) for where it lives in n8n.

> 🔒 Keep `.env` and your service-account JSON out of version control. They are already in `.gitignore`.

---

[← Installation](02-installation.md) · [Next: Running the System →](04-running.md)
