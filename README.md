<div align="center">

# Maestro AI

Get your hours back, without sacrificing the quality of what you send.

A product of Parseus AI · *Decode. Decide. Deliver.*

[Documentation](https://parseus-ai.github.io/maestro-ai/) ·
[Installation](https://parseus-ai.github.io/maestro-ai/02-installation/) ·
[Why Maestro?](https://parseus-ai.github.io/maestro-ai/why-maestro/)

</div>

---

Applying for jobs shouldn't cost you your whole day. Maestro AI helps you
discover roles, build tailored applications, and track everything in one place,
while you keep control of what represents you and every decision that matters.

It runs on your own machine and generates resumes and cover letters that match
the language of the job description. You can refine each one as many times as you
like while keeping every version, so you can always go back to an earlier draft.
It stores the job descriptions for your reference, even after a company removes
the role from its site, and it tracks your applications through their whole
lifecycle.

## Why it's different

"I just paste the job into ChatGPT." Most people do. But one model with one
prompt makes you the proofreader checking for invented claims, the auditor
finding the gaps between the job and your resume, and the one keeping track of
every version.

Maestro works differently. It uses specialized agents, each responsible for one
part of the workflow. You decide what each agent knows, how it behaves, and
which AI model runs it:

- Find roles at your target companies.
- Score every job for fit against your background.
- Tailor your resume and cover letter for each role you choose to pursue.
- Critique and fact-check the output, then hand the final call to you.
- Track applications and versions over time.
- Build from a career dossier you curate, not one inferred from past chats.

Maestro handles the mechanical work so your hours go to what actually moves the
needle: interview prep, networking, targeted reach-outs, learning.

> Maestro's contribution is the orchestration pattern, not the job search.
> Job search is the reference implementation of a domain-agnostic, multi-agent
> system with per-agent model routing and self-verifying agents. The same
> pattern generalizes to other domains.

## What's in this repo

This is the distribution repo. It contains everything you need to run Maestro
locally:

```
maestro-ai/
├── docker-compose.yml        the full stack (n8n engine + workflow importer + dashboard)
├── import-workflows.sh        seeds the workflows into n8n on first boot
├── .env.example               copy to .env and fill in
├── workflows/                 the n8n workflows (imported automatically)
├── Database_Template.xlsx     the Google Sheets database template
└── docs/                      full documentation
```

The dashboard ships as a prebuilt image, so you don't build anything from
source.

## Quick start

Maestro runs locally with Docker. You bring your own Google account and AI
provider key. The full walkthrough (including the Google Cloud and OAuth setup)
is in the [installation guide](https://parseus-ai.github.io/maestro-ai/02-installation/).

The short version, once your `.env` is filled in:

```bash
# 1. Configure
cp .env.example .env          # then edit .env

# 2. Start the stack (pulls n8n + the dashboard image, seeds the workflows)
docker compose up -d

# 3. Activate the workflows (one-time, registers the webhooks)
docker compose restart n8n
```

Then open the dashboard at http://localhost:4400.

> Setup is real but guided: you'll create a Google Cloud project, an OAuth
> client, and a service account, and copy a Sheets template. The
> [installation guide](https://parseus-ai.github.io/maestro-ai/02-installation/)
> walks through every step. Budget about half an hour the first time.

## Documentation

Full documentation lives at
[parseus-ai.github.io/maestro-ai](https://parseus-ai.github.io/maestro-ai/).

| Guide | |
|-------|--|
| [Overview](https://parseus-ai.github.io/maestro-ai/01-overview/) | What Maestro does and how it fits together |
| [Installation](https://parseus-ai.github.io/maestro-ai/02-installation/) | Full setup from scratch |
| [Configuration](https://parseus-ai.github.io/maestro-ai/03-configuration/) | Google, API keys, and the config tab |
| [Running the system](https://parseus-ai.github.io/maestro-ai/04-running/) | Day-to-day use |
| [Architecture](https://parseus-ai.github.io/maestro-ai/05-architecture/) | How the pipeline works |
| [Database reference](https://parseus-ai.github.io/maestro-ai/06-database-reference/) | Every tab and column |
| [Prompting and customizing](https://parseus-ai.github.io/maestro-ai/09-prompting/) | Editing the agents' prompts |
| [Master career dossier](https://parseus-ai.github.io/maestro-ai/10-master-dossier/) | Writing your career document |

## Try it

Download it, run it locally, and try it on one job you were already planning to
apply to. If it saves you time, a star helps others find it.

## License

Licensed under the [Elastic License 2.0](LICENSE). Free to use and self-host; you bring your own AI provider account. See [NOTICE](NOTICE).
