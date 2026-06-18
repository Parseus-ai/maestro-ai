#!/bin/sh
# Maestro AI — one-shot workflow importer (sidecar)
# Seeds the n8n workflows into the shared n8n data volume on first boot,
# then publishes the entry workflows so their webhooks register.
#
# Idempotent: a sentinel on the volume makes re-runs a no-op, so user edits
# are never clobbered on subsequent `docker compose up`.
#
# IMPORTANT: n8n must be RESTARTED after this importer runs for the published
# webhooks to register (n8n only registers webhooks at startup). The install
# docs instruct the user to run `docker compose restart n8n` once after the
# first `docker compose up -d`.
#
# Mechanism (verified):
#   1. import:workflow seeds all workflows INACTIVE.
#   2. publish:workflow --id=<id> publishes each ENTRY workflow (the 4 with
#      webhooks). Sub-workflows (agents, recorders, sources, shared) are
#      called via Execute Workflow and need no publishing.
#   3. n8n restart registers the webhooks.
#
# Workflow IDs are preserved on import, so Execute Workflow cross-references
# resolve automatically.
#
# To force a re-import: delete the sentinel inside the n8n volume and re-run.

set -e

SENTINEL="/home/node/.n8n/.maestro-imported"

# The 4 entry workflows that own webhooks (IDs are preserved on import):
#   W0Y9iSJxZ4ENLaJG  Application Orchestrator           (build-application)
#   goYMIl7DqdNoPI5x  Application Refinement             (refine-resume)
#   nTATNhjPoyJZkvem  Cover Letter Generation & Refine   (cover-letter webhook)
#   RqoWxgvwzlQIoARH  Job Discovery                      (run-discovery)
ENTRY_IDS="W0Y9iSJxZ4ENLaJG goYMIl7DqdNoPI5x nTATNhjPoyJZkvem RqoWxgvwzlQIoARH"

if [ -f "$SENTINEL" ]; then
  echo "[importer] sentinel present ($SENTINEL) — already imported, skipping."
  exit 0
fi

# Give the main n8n service a moment to initialize the SQLite schema.
echo "[importer] waiting for n8n DB to initialize..."
sleep 10

echo "[importer] importing workflows (dependency order)..."
for dir in shared sources recorders agents entry; do
  echo "[importer] === importing $dir ==="
  n8n import:workflow --separate --input="/workflows/$dir"
done

echo "[importer] publishing entry workflows (registers webhooks on next restart)..."
for id in $ENTRY_IDS; do
  echo "[importer] === publishing $id ==="
  n8n publish:workflow --id="$id"
done

# Mark done so this never re-runs and never overwrites later edits.
touch "$SENTINEL"
echo "[importer] import complete — sentinel written to $SENTINEL"
echo "[importer] NOTE: run 'docker compose restart n8n' once for webhooks to register."
