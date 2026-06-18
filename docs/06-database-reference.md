# 6. Database Reference

[← Architecture](05-architecture.md) · [Next: Troubleshooting →](07-troubleshooting.md)

---

Maestro's entire state lives in one Google Sheets file. This page documents every tab and its columns. The pipeline writes most of these; the dashboard reads them and writes back to a few. The shipped `Database_Template.xlsx` template contains all of these tabs with their headers in place.

> 💡 You rarely edit these by hand. The main exceptions are the **`config`** tab (your settings), the **`master_doc`** tab (your career history), and **`watchlist_companies`** (companies to discover jobs from), and even those are usually edited through the dashboard.

## Tab index

| Tab | What it holds |
|-----|---------------|
| [`config`](#config) | All your settings |
| [`jobs`](#jobs) | Every job: discovery scores, build status, tracking status |
| [`agent_outputs`](#agent_outputs) | Raw critic/verifier/scorer JSON per resume |
| [`resumes`](#resumes) | Every resume version generated |
| [`model_usage`](#model_usage) | Per-call token + cost log |
| [`run_state`](#run_state) | Discovery/application run lifecycle |
| [`run_errors`](#run_errors) | Catastrophic failure log |
| [`pricing`](#pricing) | Per-model token prices (for cost calc) |
| [`prompts`](#prompts) | Agent system prompts (default + override) |
| [`master_doc`](#master_doc) | Your full career history |
| [`watchlist_companies`](#watchlist_companies) | Companies to discover jobs from |
| [Other tabs](#other-tabs) | Supporting/optional features |

---

## `config`

Your settings. One row per setting; you edit the `value` column. See the [Configuration guide](03-configuration.md#the-config-tab) for what to put in each.

| Column | Purpose |
|--------|---------|
| `category` | Grouping for display |
| `parameter` | The setting key the software reads |
| `value` | **The value you set** |
| `description` | What it does |
| `examples_or_notes` | Hints |
| `display_order` | Sort order in the dashboard settings UI |
| `input_type` | How the dashboard renders the field |
| `options` | Allowed values for dropdown-type settings |

---

## `jobs`

The central tab. Every discovered or submitted job, with its discovery scores, build lifecycle, and application tracking. One row per job.

**Identity & discovery metadata:** `discovery_run_id`, `discovered_at`, `source`, `company`, `title`, `location`, `remote`, `url`, `posted_at`, `salary_text`, `jd_summary`, `description_html`, `job_id`

**Discovery scoring (Agent 8, two axes):** `title_match`, `level_match`, `role_type_match`, `domain_match`, `location_match`, `salary_signal`, `restrictions_text`, `strengths`, `gaps`, `jd_score_rationale`, `overall_score`, `verdict`, `background_overall_score`, `background_verdict`, `restrictions_json`, `prompt_warnings`

**Discovery cost:** `discovery_tokens_in`, `discovery_tokens_out`, `discovery_cost_usd`, `discovery_model_used`

**Build lifecycle:** `job_status` (`'' | hide`), `build_application` (flag to build), `processed_status` (`'' | queued | processing | done | error`), `application_run_id`, `error_log`

**Build outputs:** `resume_folder_url`, `resume_generated_at`, `model_used`, `resume_fit_score`, `recommendation`, `resume_score_rationale`, `cover_letter_markdown`

**Build cost & totals:** `application_tokens_in`, `application_tokens_out`, `application_cost_usd`, `total_tokens_in`, `total_tokens_out`, `total_cost`

**Application tracking (dashboard):** `application_status`, `applied_at`, `status_updated_at`, `notes`, `next_action`, `next_action_due_at`

`application_status` enum: `not_applied | applied | screening | interviewing | final_round | offer | rejected | withdrew | ghosted | do_not_apply` (blank reads as not-reviewed).

---

## `agent_outputs`

The raw structured output behind each resume, what the critic, verifier, and scorer actually produced. One row per resume version.

| Column | Meaning |
|--------|---------|
| `url` | Job URL (links to `jobs`) |
| `application_run_id` | Cross-tab join key |
| `resume_id` | `{job_id}_v{version}`, version discriminator |
| `verifier_output_json` | Verifier findings (JSON) |
| `critic_output_json` | Critic findings (JSON; populated for original builds, blank for refinements) |
| `scorer_output_json` | Scorer breakdown (JSON) |
| `generated_at` | Timestamp |
| `job_id` | Links to `jobs` |

---

## `resumes`

Every resume version. Version 1 is the original build; 2+ are refinements. One row per version.

| Column | Meaning |
|--------|---------|
| `resume_id` | `{job_id}_v{version}` |
| `job_id`, `application_run_id`, `url`, `company`, `title` | Job linkage |
| `version` | 1 = original, 2+ = refinement |
| `parent_resume_id` | The version this was refined from |
| `source` | `original` / `polish` / `refine` |
| `resume_markdown` | The resume content |
| `refinement_instructions` | Your instructions for this version |
| `ran_verifier`, `ran_critic` | Whether each ran for this version |
| `overall_score`, `recommendation`, `score_delta` | Fit score + change vs parent |
| `verifier_verdict`, `unsupported_count`, `critic_critical_count` | Quality signals |
| `tokens_in`, `tokens_out`, `cost_usd` | Cost for this version |
| `drive_url` | The saved `.docx` URL (written by "Save to Drive"; blank until saved) |
| `created_at` | Timestamp |

> 📌 `drive_url` is **output-only** and also serves as an idempotency check, if it's already set, "Save to Drive" treats the version as saved. The pipeline leaves it blank on purpose.

---

## `model_usage`

A per-call log of every LLM invocation. The basis for all cost reporting.

| Column | Meaning |
|--------|---------|
| `run_id` | The run this call belonged to |
| `agent_name` | Which agent made the call |
| `provider`, `model_used` | Which provider/model |
| `status` | `ran` / `disabled` / `error` |
| `generated_at` | Timestamp |
| `tokens_in`, `tokens_out`, `cached_input_tokens`, `cache_write_tokens` | Token counts |
| `cost_usd` | Dollar cost of this call |
| `job_id` | Links to `jobs` (blank for discovery scoring, which runs before the ID is minted) |

---

## `run_state`

Run lifecycle for the dashboard's "currently running / last run" banner. **Two rows per workflow** (a `current` slot and a `last` slot), matched on a composite `state_key`.

| Column | Meaning |
|--------|---------|
| `state_key` | Composite match key (e.g. `discovery_current`) |
| `workflow` | Which pipeline |
| `status` | `running \| completed \| idle` |
| `run_id`, `source` | The run and what triggered it |
| `started_at`, `completed_at` | Timestamps |
| `jobs_returned` | Count from the last run |
| `database_id` | Which database this run targeted |

---

## `run_errors`

Catastrophic failures captured by the Run Error Handler.

`run_id`, `failed_at`, `workflow_name`, `workflow_id`, `execution_id`, `execution_url` (debug link), `last_node`, `error_name`, `error_message`, `error_stack`

---

## `pricing`

Per-model token prices. **Every model you reference in `config` must have a row here**, or cost calculation throws.

| Column | Meaning |
|--------|---------|
| `provider` | `anthropic` / `openai` / `gemini` |
| `model` | Must match the config model name exactly |
| `input_per_million` | \$ per million input tokens |
| `output_per_million` | \$ per million output tokens |
| `cached_input_per_million` | \$ per million cached-read tokens |
| `cache_write_per_million` | \$ per million cache-write tokens |

Rule of thumb: Anthropic cached ≈ 10% of input, cache-write ≈ 125%. OpenAI/Gemini cached ≈ 10% of input, cache-write = 0.

---

## `prompts`

The agents' system prompts, editable without touching code.

| Column | Meaning |
|--------|---------|
| `agent_id` | Which agent |
| `default_markdown` | The shipped prompt |
| `override_markdown` | Your custom prompt (takes precedence if set) |
| `updated_at`, `description` | Metadata |

---

## `master_doc`

Your complete career history as `key`/`value` rows. Every resume draft pulls from this; agents are forbidden from inventing anything not present here. Edited via the dashboard's Master Doc page.

| Column | Meaning |
|--------|---------|
| `key` | Section/field name |
| `value` | Content |

---

## `watchlist_companies`

Companies discovery polls for open roles.

| Column | Meaning |
|--------|---------|
| `company_name` | Display name (key) |
| `domain`, `category`, `priority` | Metadata |
| `greenhouse_slug`, `lever_slug`, `ashby_slug`, `workday_url`, `careers_url` | ATS identifiers for fetching jobs |
| `ats_last_polled_at`, `jobs_found_last_poll` | Poll bookkeeping |
| `added_at`, `note` | Metadata |

---

## Other tabs

These support optional or in-development features. Most users won't touch them.

| Tab | Purpose |
|-----|---------|
| `jsearch_usage` | JSearch API quota tracking |
| `slug_failures` | Records ATS slugs that failed to fetch (for cleanup) |
| `companies` | Company research/intel reports |
| `watchlist_signals` | Outreach signal tracking |
| `outreach_intel`, `outreach_contacts`, `outreach_events`, `outreach_suggestions` | Outreach CRM (future feature) |

---

[← Architecture](05-architecture.md) · [Next: Troubleshooting →](07-troubleshooting.md)
