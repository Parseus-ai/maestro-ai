# 11. Importing the Workflows into n8n

[← Master Career Dossier](10-master-dossier.md) · [Home →](index.md)

---

Importing is automatic. The first time you run `docker compose up -d`, a one-shot sidecar service (`n8n-importer`) seeds all 31 of Maestro's workflows into n8n, publishes the four entry workflows, and then exits. You do not import anything by hand.

The four entry workflows it publishes are Application Orchestrator, Application Refinement, Cover Letter Generation & Refinement, and Job Discovery. The other workflows are sub-workflows, called via Execute Workflow, and do not need publishing.

The importer is idempotent. After a successful run it writes a sentinel file inside the n8n data volume and skips on every later start, so your own edits to the workflows are never overwritten.

## Restart n8n once after the first start

n8n only registers webhooks for published workflows at startup. The importer publishes the entry workflows while n8n is already running, so you must restart n8n once for their webhooks to register:

```bash
docker compose restart n8n
```

Without this one-time restart, the dashboard's trigger calls return 404 because the webhooks are not yet registered. You only need it after the first `docker compose up -d`, or after a forced re-import (below).

## Verify it worked

Confirm the import in either of two ways:

- In the n8n UI, open http://localhost:5678 and check the Workflows list. All of Maestro's workflows should be present, and the four entry workflows should show as Active.
- In the importer logs:

  ```bash
  docker compose logs n8n-importer
  ```

  A successful first run ends with:

  ```
  [importer] import complete — sentinel written to /home/node/.n8n/.maestro-imported
  ```

  On later starts you will see `sentinel present ... skipping` instead. That is normal and means the workflows are already imported.

> ℹ️ Importing seeds and publishes the workflows but does not connect your credentials. You still do that once by hand: the Google service account, the AI provider key, the webhook secret, and the database ID in the Run Error Handler. See [Installation, Connect n8n credentials](02-installation.md#step-9-connect-n8n-credentials).

## Force a re-import

To re-seed the shipped workflows (for example after pulling updates), delete the sentinel, re-run the importer, then restart n8n. This overwrites the shipped workflows, so back up your own edits first.

```bash
# 1. Remove the sentinel (n8n is running, so reach the volume through it)
docker compose exec n8n rm -f /home/node/.n8n/.maestro-imported

# 2. Re-run the one-shot importer
docker compose run --rm n8n-importer

# 3. Restart n8n so the republished webhooks register
docker compose restart n8n
```

If n8n is not running, remove the sentinel from the named volume directly, then start the stack:

```bash
docker run --rm -v maestro_n8n_data:/v alpine rm -f /v/.maestro-imported
docker compose up -d
docker compose restart n8n
```

---

[← Master Career Dossier](10-master-dossier.md) · [Home →](index.md)
