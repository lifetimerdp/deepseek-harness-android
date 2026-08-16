# DeepSeek Harness for Android

Run a coding agent on any Android phone - no root required.
By default it ships the official DeepSeek Harness (dsh) with DeepSeek
models, but the stack is provider-agnostic: any OpenAI-compatible endpoint
(OpenRouter, Groq, OpenAI, Azure, local Ollama, ...) can be plugged in
via environment overrides.

Stack: Termux, proot Ubuntu, Node.js with real node-pty, web UI on port 3080.
All project data lives in /sdcard/projects, outside Termux private storage,
so a Termux reset never destroys your work.

## Requirements

- Android 8+, about 1.5 GB free storage
- Termux from F-Droid (the Play Store build is obsolete and breaks)
- An API key from any OpenAI-compatible provider (DeepSeek by default)
- Stable internet during first install; keep the charger in

## Quick start (fresh phone)

1. Install and open Termux.
2. Grant storage access:

       termux-setup-storage

   Tap Allow.

3. Run the one-line installer:

       curl -fsSL https://raw.githubusercontent.com/lifetimerdp/deepseek-harness-android/main/boot.sh | bash

4. Answer three prompts (only the key is required; the rest may be blank):

       API key (DeepSeek or OpenAI-compatible): <paste your key>
       Base URL (Enter = DeepSeek official):    <blank or your endpoint>
       Model (Enter = deepseek-v4-flash):       <blank or a model id>

   Answers are stored once at /sdcard/projects/.dsh-env (mode 600).

5. Wait for the final banner (10-30 minutes depending on network):

       == DONE: open http://127.0.0.1:3080 ==

6. Open http://127.0.0.1:3080 and pick your model in the UI model menu.

## Custom providers (optional)

A DeepSeek key alone is enough for the default setup. To use another
endpoint, add or edit exports in /sdcard/projects/.dsh-env, then restart:

| Variable | Meaning |
|---|---|
| DEEPSEEK_API_KEY | key for the default deepseek-official provider |
| DEEPSEEK_BASE_URL | override the DeepSeek endpoint (proxy/relay) |
| DEEPSEEK_DEFAULT_MODEL | default model id for that endpoint |
| OPENAI_API_KEY | key for the built-in OpenAI-compatible provider |
| OPENAI_BASE_URL | its endpoint |
| OPENAI_API_TYPE | wire format (chat completions vs responses) |
| OPENAI_API_VERSION | api-version header (Azure-style endpoints) |

Example OPENAI_BASE_URL values:

- OpenAI: https://api.openai.com/v1
- OpenRouter: https://openrouter.ai/api/v1
- Groq: https://api.groq.com/openai/v1
- Ollama (local): http://127.0.0.1:11434/v1

The installer stores your key under both DEEPSEEK_API_KEY and
OPENAI_API_KEY so either provider can be selected from the UI model menu.

## What the installer does

1. Points Termux at a package mirror (edit the sources.list line in
   tools/pasang.sh to change it).
2. Installs base packages non-interactively (curl, proot-distro,
   OpenJDK 17, Android build tools).
3. Installs an Ubuntu proot container.
4. Sets up Node.js 22 and the official @deepseek-ai/dsh with node-pty.
5. Applies bundled fixes (fixkey.sh, fixpty.sh).
6. Writes the launcher and starts the web UI on port 3080.

Idempotent: safe to re-run; only harness files are overwritten,
never your project data.

## Recovering a broken Termux

1. Android Settings, Apps, Termux, Clear Data.
2. Re-run the Quick start. Everything in /sdcard/projects survives.

## Updating

Re-run the one-liner from step 3.

## Repository layout

    boot.sh            bootstrap: download repo, copy harness, run installer
    tools/pasang.sh    idempotent installer (non-interactive packages)
    tools/fixkey.sh    SSH key / permission fix
    tools/fixpty.sh    node-pty fix
    tools/build-apk.sh APK build pipeline
    AGENTS.md          on-device SOP the agent reads (Indonesian by design)

## Security

- No API keys or secrets in this repository.
- Keys are typed once on-device into /sdcard/projects/.dsh-env (mode 600).
- boot.sh downloads only from this repository over HTTPS.
- Rotate leaked keys at your provider.

## Troubleshooting

- Permission errors: run termux-setup-storage, tap Allow, re-run.
- Looks stuck: network speed; keep charger in; optionally termux-wake-lock.
- Port 3080 in use: stop the old instance or reboot, then re-run.
- Wrong key or provider: edit /sdcard/projects/.dsh-env, restart dsh.

## License

MIT. Unofficial project, not affiliated with DeepSeek or Termux.
