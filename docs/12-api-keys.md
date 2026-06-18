# Getting AI Provider Keys

[← Configuration](03-configuration.md) · [Home →](index.md)

---

Maestro runs on AI models you supply. You bring your own key from one of three
providers: Anthropic, OpenAI, or Google Gemini. The Maestro software is free;
the AI calls it makes are billed by your provider, to you, at cost.

You only need one provider to start. You can mix providers later by assigning
different models to different agents (see [Configuration](03-configuration.md)).

This page covers how to create a key and set up billing with each provider.
For where to enter the key, see
[Connect n8n credentials](02-installation.md#step-9-connect-n8n-credentials).
Keys are entered in n8n only. They never go in your `.env` file.

## What it costs

A typical tailored application (resume plus cover letter, with the critique and
fact-check passes) costs roughly $0.06 to $0.12 in provider charges, depending
on the models you choose. A few dollars of credit covers a lot of applications.

Maestro records the cost of every run in the `model_usage` tab of your database,
so you can see exactly what you are spending.

## Google Gemini (free tier available)

Gemini is the easiest way to try Maestro at no cost. Google offers a free tier
through AI Studio that is enough to test the system on a few applications.

1. Go to [aistudio.google.com/apikey](https://aistudio.google.com/apikey) and
   sign in with a Google account.
2. Select Create API key.
3. Copy the key and keep it somewhere safe.

The free tier has rate and usage limits. To raise them, enable billing on the
associated Google Cloud project from the same AI Studio screen. Current limits
and pricing are on Google's
[Gemini API pricing page](https://ai.google.dev/pricing).

## Anthropic (Claude)

1. Sign up at [console.anthropic.com](https://console.anthropic.com).
2. Open Billing and add a small amount of credit. $5 to $10 is plenty to start.
3. Open API Keys, select Create Key, and copy the key. It begins with
   `sk-ant-`.

Anthropic is prepaid: you add credit, and calls draw it down. Current model
pricing is on the
[Anthropic pricing page](https://www.anthropic.com/pricing).

## OpenAI

1. Sign up at [platform.openai.com](https://platform.openai.com).
2. Open Billing (under Settings) and add a payment method or prepaid credit.
   OpenAI requires billing to be set up before API calls will succeed, even on
   a new account.
3. Open [platform.openai.com/api-keys](https://platform.openai.com/api-keys),
   select Create new secret key, and copy it. It begins with `sk-`.

Current model pricing is on the
[OpenAI pricing page](https://openai.com/api/pricing).

## After you have a key

Enter it in n8n, not in `.env`. The dashboard makes no AI calls itself; the
keys live in n8n's Header Auth credentials, assigned to the Call LLM nodes. The
exact header for each provider, and the step-by-step, are in
[Connect n8n credentials](02-installation.md#step-9-connect-n8n-credentials)
and the
[AI provider credentials](03-configuration.md#ai-provider-credentials)
reference.

---

[← Configuration](03-configuration.md) · [Home →](index.md)
