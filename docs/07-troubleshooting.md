# 7. Troubleshooting

[← Database Reference](06-database-reference.md) · [Next: FAQ & Glossary →](08-faq-glossary.md)

---

Common problems and how to fix them. Issues are grouped by where they show up.

## Installation & startup

### `docker` or `node` "command not found"

The program isn't installed or isn't on your PATH. Re-run the [prerequisite installs](02-installation.md#step-1-install-prerequisite-software), then **close and reopen your terminal** so it picks up the new commands.

### Docker says it can't connect / "daemon not running"

Docker Desktop isn't running. Launch it and wait for "Docker Desktop is running" before retrying.

### The dashboard won't start / port 4400 in use

Another process is using port 4400. Stop it, or change `DASHBOARD_PORT` in your `.env` and restart the stack with `docker compose up -d`.

---

## Google Sheets / Drive connection

### Dashboard loads but shows no data / "permission denied"

Almost always one of:

1. **The Sheet isn't shared with the service account.** Open the Sheet → Share → add the `client_email` from your service-account JSON as **Editor**.
2. **The private key is mangled.** In `.env`, `GOOGLE_SHEETS_PRIVATE_KEY` must be on one line, wrapped in double quotes, with the `\n` sequences intact exactly as they appear in the JSON file. Don't reformat or add real line breaks.
3. **Wrong `GOOGLE_SHEETS_DATABASE_ID`.** Re-copy it from the Sheet's URL (the long part between `/d/` and `/edit`).

### "Save to Drive" fails with 403 Forbidden

The classic mismatch: **the dashboard and the pipeline are using different service accounts.** The pipeline created the Drive folder; the dashboard can't write into a folder it doesn't own access to. Fix: ensure `GOOGLE_SHEETS_CLIENT_EMAIL` in the dashboard matches the service account configured in n8n's Google credential, and that this account has Editor access to the `ROOT_FOLDER_ID` folder.

### APIs not enabled

If Sheets/Drive/Docs calls fail outright, confirm all three APIs are **Enabled** in your Google Cloud project (Sheets, Drive, Docs).

---

## n8n / pipeline

### Clicking "Build" does nothing / trigger returns 503

The single most common setup failure is a webhook secret that doesn't match. The dashboard sends an `X-Maestro-Secret` header that must equal what n8n expects.

- Confirm `MAESTRO_WEBHOOK_SECRET` in your `.env` is set (not blank).
- Confirm the **exact same value** is in n8n's `X-Maestro-Secret` Header Auth credential, and that credential is selected on all three entry workflows' Webhook nodes.
- A blank secret makes the dashboard's trigger routes return 503.
- Also confirm `N8N_WEBHOOK_BASE_URL` ends in `/webhook` (not `/webhook-test`).

### A workflow fails: "could not find workflow" / sub-workflow not called

The importer seeds and publishes the four entry workflows automatically; the agents, recorders, and sources are called as sub-workflows and do not need publishing. If trigger calls 404 right after first start, you likely skipped the one-time `docker compose restart n8n` that registers the entry webhooks. See [Importing the Workflows](11-importing-workflows.md).

### After editing a sub-workflow's inputs, the parent passes wrong/empty data

Two likely causes:

1. **Schema cache is stale.** Click the refresh ⟳ icon on the parent's Execute Workflow node after changing the child's trigger schema.
2. **A field is typed `String` instead of `Object`.** Fields like `config`, `critique`, `verifier` must be `Object` in the trigger schema. String typing makes n8n stringify them, breaking lookups like `config.model_X`.

### `#NAME?` errors in Google Sheets nodes

You mixed `={{ }}` and `{{ }}` expression syntax, or manually typed a leading `=` in an expression-mode field. Use the syntax appropriate to that node type and don't hand-type the `=`.

### JSON parse error in an agent, and output tokens equal the max

The model's response was **truncated by the token cap.** Raise that agent's `max_tokens_*` value in the `config` tab and re-run.

### Agent throws "missing provider/model" instead of running

This is intentional, Maestro has no silent fallback model. The agent's `provider_*` / `model_*` key in `config` is blank or missing. Set it, and make sure the model has a matching row in the `pricing` tab.

### A model_usage row shows `disabled` with all zeros

The agent's usage record wasn't forwarded (often a model name with no `pricing` row, or a disabled agent). Confirm the model exists in `pricing` and the agent is enabled in `config`.

### `parent_execution_id` error from Data Loader

A caller invoked Data Loader without passing `parent_execution_id = {{ $execution.id }}`. This is a workflow wiring bug, add the input on the calling node.

### A run crashed and left a job stuck as "running"

If the Run Error Handler isn't wired to that entry workflow, a crash can orphan run state. Set the workflow's **Error Workflow** (Settings → Error Workflow → Run Error Handler) so failures are captured and state is cleared. You can also reset stuck state manually in the `run_state` tab.

---

## Discovery & scoring

### Discovery returns nothing

- Check `watchlist_companies` has companies with valid ATS slugs (`greenhouse_slug`, `lever_slug`, `ashby_slug`).
- Check `discovery_max_jobs_per_run` isn't set so low that only one job survives ranking.
- Bad slugs are logged in `slug_failures`, review and fix them.

### Every job comes back "no fit" even good matches

This is the target/background collapse symptom. Confirm in `config` that `target_*` fields describe the role you want and that your `profile_summary` (which describes *you*) is **not** doubling as a target field. The two scoring axes must stay separated. See [Architecture → two scoring axes](05-architecture.md#the-two-scoring-axes).

---

## Refinement

### Refine succeeds but the new version reads the wrong data

Test in order: **build → polish → refine.** The first refinement (a *polish*) reads version 1's original critique and verification. A later *refine* needs a prior polish to have written its verifier output. Running refine before any polish exists looks like a bug but isn't, there's no parent verifier row to read yet.

---

## When all else fails

1. **Trust live data over snapshots.** The `Database_Template.xlsx` in the repo and any exports go stale quickly. The live Google Sheet is the source of truth.
2. **Check the n8n execution log.** Open the failed execution in n8n; the red node and its error message usually point straight at the cause.
3. **Check `run_errors`.** Catastrophic failures land here with an execution URL you can open directly.
4. **Revert to the last working state** rather than iterating on a broken workflow, re-import the workflow JSON from the repo if a node got mangled.

---

[← Database Reference](06-database-reference.md) · [Next: FAQ & Glossary →](08-faq-glossary.md)
