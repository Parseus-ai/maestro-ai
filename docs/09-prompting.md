# 9. Prompting & Customizing the Agents

[← FAQ & Glossary](08-faq-glossary.md) · [Next: Your Master Career Dossier →](10-master-dossier.md)

---

Every agent in Maestro is driven by a **system prompt**, a structured instruction set that tells the AI exactly what to do. These prompts live in the `prompts` tab of your database, and you can edit them without touching any code. This page explains the framework they follow, *why* it works, and how to customize them safely.

> 💡 **You don't have to touch prompts to use Maestro.** The defaults are tuned and ship ready to run. Read this only when you want to change an agent's behavior, e.g. a different resume style, stricter fact-checking, or a new tone.

## Where prompts live

Each of the ten agents has one row in the `prompts` tab:

| Column | Meaning |
|--------|---------|
| `agent_id` | Which agent (`agent_1` … `agent_10`) |
| `default_markdown` | The shipped prompt, **leave this alone** |
| `override_markdown` | **Your custom prompt.** If set, it replaces the default for that agent. |
| `updated_at`, `description` | Metadata |

```
prompts tab
┌──────────┬──────────────────────┬──────────────────────┬─────────────────────┐
│ agent_id │ default_markdown      │ override_markdown     │ description          │
├──────────┼──────────────────────┼──────────────────────┼─────────────────────┤
│ agent_1  │ ## ROLE\nYou are a…   │  ← (empty: uses       │ Resume Builder       │
│          │ [the shipped prompt]  │     default)          │                      │
│ agent_5  │ ## ROLE\nYou are a…   │ ## ROLE\nYou are a…   │ Critic               │
│          │ [the shipped prompt]  │ [YOUR version wins]   │                      │
└──────────┴──────────────────────┴──────────────────────┴─────────────────────┘
                                          ▲
                          Put your edits HERE, not in default_markdown.
                          Blank override = the default is used.
```

**The override pattern is your safety net:** the original prompt always stays intact in `default_markdown`. To revert a customization, just clear your `override_markdown` cell.

## The agent roster at a glance

| `agent_id` | Agent | What its prompt controls |
|-----------|-------|--------------------------|
| `agent_1` | Resume Builder | How resumes are drafted and structured |
| `agent_2` | Cover Letter Builder | Cover letter style and content |
| `agent_3` | Resume Verifier | How strictly claims are fact-checked |
| `agent_4` | Cover Letter Verifier | Fact-checking for cover letters |
| `agent_5` | Critic | What counts as a weakness worth fixing |
| `agent_6` | Resume Refiner | How the first refinement (polish) applies critique |
| `agent_7` | Resume Scorer | How fit scores are assigned |
| `agent_8` | Discovery Scorer | How discovered jobs are scored (two axes) |
| `agent_9` | Resume Fine-Refiner | How later refinements apply your instructions |
| `agent_10` | Job Ranker | How the fast first-pass ranking works |

---

## The prompt framework

Every Maestro prompt follows the **same skeleton**. This consistency is deliberate, it's what makes the system predictable, debuggable, and safe to edit. Learn the skeleton once and you can read or modify any agent.

```
## ROLE              ← who the agent is, in one or two sentences
## CONTEXT           ← what inputs it receives, and which is the source of truth
## INSTRUCTIONS      ← the concrete output structure (builders)
   or
## WHAT TO EVALUATE  ← what to inspect (verifiers / critics / scorers)
## METHOD            ← the step-by-step procedure to follow
## TONE & VOICE      ← style rules (builders only)
## SEVERITY GUIDANCE ← how to rank issues (verifiers / critics)
   or
## SCORING GUIDANCE  ← how to assign numbers (scorers)
## CONSTRAINTS       ← hard "do NOT" rules — the guardrails
## EDGE CASES        ← how to handle tricky inputs
## SUCCESS CRITERIA  ← what a good output looks like
## EXAMPLES          ← worked good/bad examples
```

Not every agent uses every section, a builder has `INSTRUCTIONS` and `TONE & VOICE`; a verifier has `WHAT TO EVALUATE` and `SEVERITY GUIDANCE` instead. But the spine is always the same, in the same order.

### Why each section earns its place

| Section | The problem it solves |
|---------|----------------------|
| **ROLE** | Sets the persona so the model adopts the right expertise and standards from the first token. |
| **CONTEXT** | Names the inputs and, critically, declares the **single source of truth** (the master document). This is what stops fabrication. |
| **INSTRUCTIONS / WHAT TO EVALUATE** | Pins the output to an exact structure, so results are consistent and the pipeline can parse them. |
| **METHOD** | A numbered procedure turns a vague task into repeatable steps, which dramatically improves reliability. |
| **CONSTRAINTS** | Explicit "do NOT" rules are the guardrails. "Do NOT invent facts" is the single most important line in the whole system. |
| **EDGE CASES** | Pre-answers the ambiguous situations (sparse JD, employment gaps, thin experience) so the model doesn't improvise badly. |
| **SEVERITY / SCORING GUIDANCE** | Calibrates judgment to a shared scale, so a "critical" issue means the same thing every run. |
| **SUCCESS CRITERIA** | Gives the model a target to self-check against before it answers. |
| **EXAMPLES** | One concrete good-vs-bad pair teaches more than a paragraph of description. |

### Why this framework works

Three principles make it effective:

1. **Truth is structural, not hoped-for.** The system doesn't *ask* the model to be honest, it *architects* honesty. The master document is declared the sole source of truth in `CONTEXT`, fabrication is forbidden in `CONSTRAINTS`, and a separate Verifier agent (Agent 3) independently fact-checks the result. Honesty is enforced at three layers, not one.

2. **Specific beats vague, everywhere.** Vague prompts produce vague output. The framework forces specificity at every turn: a numbered `METHOD`, an explicit output structure, calibrated severity scales, and worked `EXAMPLES`. The Critic's own prompt says it best: *"vague feedback produces vague fixes."*

3. **Separation of powers.** No single agent both writes and judges its own work. The Builder drafts, the Critic critiques, the Refiner fixes, the Verifier fact-checks, the Scorer rates. Each prompt has one job and does it well, which is easier to get right, easier to debug, and harder to fool.

### A real example: the Resume Builder (Agent 1)

Here's how the skeleton looks filled in (excerpted from the shipped default):

```markdown
## ROLE
You are a professional resume writer. You produce a tailored resume that
matches a specific job description while staying faithful to the candidate's
actual career history…

## CONTEXT
You will receive:
1. A job description (JD) for a specific role.
2. The candidate's master career document — the authoritative source for
   every role, achievement, metric, and credential the candidate actually has.
Your output is a tailored resume in markdown, drawn entirely from facts in
the master document. You select and emphasize relevant content; you never
invent it.

## INSTRUCTIONS
Produce the resume using this standard structure, in order:
1. Headline …
2. Professional Summary …
3. Professional Experience …

## CONSTRAINTS
- Do NOT invent facts; every claim must trace to the master document.
- Do NOT fabricate or alter metrics, titles, employers, or dates.
- Do NOT inflate the candidate's seniority …

## EXAMPLES
Example A — bullet point (weak to strong):
WEAK:   "Responsible for managing the team and improving processes."
STRONG: "Managed a 6-person team and streamlined the intake process,
         reducing turnaround time by 30%."
WHY: the strong version uses an action verb, specifies scope, and
     quantifies the result.
```

Notice how `CONTEXT` names the master document as authoritative, `CONSTRAINTS` forbids invention three different ways, and `EXAMPLES` shows the exact quality bar. That's the framework doing its job.

---

## How to customize a prompt

### Step 1, Read the default first

Open the `prompts` tab, find your agent's row, and read its `default_markdown` end to end. You can't safely edit what you don't understand, and the defaults already handle most cases.

### Step 2, Copy it into `override_markdown`

Copy the **entire** `default_markdown` into the same row's `override_markdown` cell. Always start from the full default, never write an override from scratch, or you'll lose the guardrails that keep the system honest.

### Step 3, Make your change *inside* the framework

Edit the section that owns your change. Keep the skeleton intact.

| You want to… | Edit this section |
|--------------|-------------------|
| Change resume tone or length | `TONE & VOICE` and/or `INSTRUCTIONS` |
| Add/remove a resume section | `INSTRUCTIONS` |
| Make fact-checking stricter or looser | `SEVERITY GUIDANCE` and `CONSTRAINTS` in Agent 3 |
| Change what the critic flags | `WHAT TO EVALUATE` and `SEVERITY GUIDANCE` in Agent 5 |
| Adjust how fit scores are assigned | `SCORING GUIDANCE` in Agent 7 / Agent 8 |
| Add a rule the agent keeps breaking | Add a line to `CONSTRAINTS` |
| Teach the agent a tricky case | Add a bullet to `EDGE CASES` |

### Step 4, Test on one job

Run a single build (or discovery) and inspect the result. If it's worse, clear the `override_markdown` cell to instantly revert to the default.

### Golden rules for editing

- ✅ **Always keep the source-of-truth and no-fabrication rules.** If you remove "do NOT invent facts" from a builder, you break the whole honesty guarantee.
- ✅ **Add constraints as explicit "do NOT" lines.** Models follow concrete prohibitions far better than vague preferences.
- ✅ **Update the EXAMPLES if you change the output.** A stale example confuses the model more than no example.
- ✅ **Change one thing at a time, then test.** Multiple simultaneous edits make failures impossible to diagnose.
- ❌ **Don't delete whole sections** unless you truly understand the consequence, each one is load-bearing.
- ❌ **Don't make builder prompts judge themselves**, that's the verifier's and critic's job, by design.

---

## Prompting tips that transfer

These principles apply whether you're editing Maestro's prompts or writing your own anywhere:

- **Be specific and detailed.** "Quantify results where the master document provides numbers" beats "make it impressive."
- **Use positive *and* negative examples.** Show the good version and the bad version, and say *why*.
- **Encourage step-by-step reasoning.** A numbered `METHOD` produces more reliable output than a single instruction.
- **State the output format explicitly.** If you need structured output, describe its shape exactly.
- **Name the constraints.** The things you *don't* want are as important as the things you do.

For a deeper reference on prompting, see Anthropic's guide: <https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview>.

---

[← FAQ & Glossary](08-faq-glossary.md) · [Next: Your Master Career Dossier →](10-master-dossier.md)
