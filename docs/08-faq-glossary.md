# 8. FAQ & Glossary

[← Troubleshooting](07-troubleshooting.md) · [Next: Prompting & Customizing →](09-prompting.md)

---

## Frequently asked questions

**Does Maestro apply to jobs for me?**
No. Maestro discovers, scores, drafts, and tracks. The actual decision to apply, and the act of applying, is always yours. It prepares; you act.

**How much does it cost to run?**
Maestro is free to use and self-hosted; you pay only the AI providers for the tokens used. A full application build runs about **\$0.06–\$0.12**; discovery scoring is a few cents per run. You set the budget by choosing models and limits.

**Do I have to use Anthropic?**
No, Anthropic is the recommended default, but OpenAI and Google Gemini are fully supported. You can even mix providers per agent in the `config` tab.

**Can it invent things on my resume?**
The design actively prevents it. The Resume Builder works only from your master document, and a dedicated Verifier agent fact-checks every resume against your profile to catch unsupported claims. You also review everything before using it.

**Where is my data stored?**
In your own Google account, a Google Sheet (the database) and a Google Drive folder (files). Maestro doesn't send your data anywhere except to the AI provider(s) you configure, for the specific calls that generate content. The system's access is scoped to only the Sheet and folder you explicitly share with its service account, not your whole Drive. If you'd still rather not connect your personal account at all, create a free dedicated (burner) Google account just for Maestro and use it throughout setup; everything works identically.

**Do I need to keep my computer on?**
The backend and dashboard run on your machine, so they need to be running while you work. Start them when you want to work, run discovery and builds, then stop them when you are done.

**Can I run only the backend or only the dashboard?**
You can run discovery and builds entirely from n8n without the dashboard, but the dashboard is where reviewing, refining, and tracking are pleasant. They share the same database, so they stay in sync.

**Why n8n if you plan to move off it?**
n8n was a fast way to build and demonstrate the multi-agent pipeline visually. The long-term plan is to migrate orchestration into the app. The architecture is built so that migration changes only a few webhook URLs.

**One of the files is named `Abshy_Source`, is that a bug?**
It's a misspelling of **Ashby** (a job board source). The workflow works correctly; only the name is wrong.

**Can I submit my own jobs?**
Yes, the dashboard's **Submit** page takes a single job (a form) or a bulk CSV/XLSX upload. Submitted jobs skip discovery scoring and build immediately, with priority over discovered ones. Maestro deduplicates by URL so you won't accidentally rebuild the same job.

**Can I add companies to discover jobs from?**
Yes, add rows to the `watchlist_companies` tab with the company's ATS slug (Greenhouse, Lever, or Ashby). Discovery will poll them.

**Can I customize the agents' instructions?**
Yes, the `prompts` tab holds each agent's system prompt. Set an `override_markdown` value to use your own version without touching code.

---

## Glossary

**Agent**: One of the ten specialist AI workers in the pipeline (resume builder, critic, scorer, etc.). Each is an n8n sub-workflow with a focused job.

**Application Orchestrator**: The entry workflow that builds a full application (resume + cover letter + scoring) for selected jobs.

**Background fit**: A fit score answering "does this job match the candidate's actual experience?" Contrast with *target fit*.

**Build**: Generating a tailored application for a job. Triggered from the dashboard.

**Call LLM**: The shared module every agent uses to talk to AI providers, so provider differences, retries, and cost tracking live in one place.

**Container**: A self-contained, packaged program that Docker runs. n8n, the importer, and the dashboard each run in a container.

**Discovery**: Finding and scoring open jobs from company career pages and job APIs.

**Docker**: Software that runs programs in isolated containers so you don't have to install their dependencies manually.

**Environment variable**: A setting (often a secret) stored in a `.env` file that a program reads at startup.

**n8n**: The visual automation tool the backend pipeline is built in.

**Master document**: Your complete career history (in the `master_doc` tab). Every resume draft pulls from it; agents can't invent beyond it.

**Polish**: The first refinement of a resume, re-working version 1 using the original critique and verification.

**Refine**: A later refinement, building on the previous version.

**run_id**: A per-execution trace identifier, prefixed `app_`, `disc_`, or `refine_`.

**application_run_id**: The key that joins related rows across the `jobs`, `resumes`, and `agent_outputs` tabs.

**resume_id**: Identifies a specific resume version, formatted `{job_id}_v{version}`.

**Service account**: A non-human Google identity with its own key, letting Maestro read/write your Sheet and Drive automatically.

**Sub-workflow**: A reusable n8n workflow called by another workflow (all the agents and recorders are sub-workflows).

**Target fit**: A fit score answering "does this job match the role being searched for?" Contrast with *background fit*.

**Verifier**: An agent that fact-checks generated content against your profile to prevent invented claims.

**Watchlist**: The list of companies (in `watchlist_companies`) that discovery polls for open roles.

**Webhook**: A URL that one system calls to trigger an action in another. The dashboard uses webhooks to tell the pipeline to run.

---

[← Troubleshooting](07-troubleshooting.md) · [Next: Prompting & Customizing →](09-prompting.md)
