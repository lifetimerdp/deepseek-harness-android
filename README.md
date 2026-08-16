# DeepSeek Harness for Android

Run a DeepSeek coding agent (dsh) on any Android phone — no root required.
Stack: Termux, proot Ubuntu, Node.js with real node-pty, web UI on port 3080.

Designed for one-command installs on fresh devices and for surviving Termux
resets: all project data lives in /sdcard/projects, outside Termux storage.

## Requirements

- Device: Android 8+, about 1.5 GB free storage
- Termux: install from F-Droid (the Play Store build is obsolete and breaks)
- API key: a DeepSeek API key (platform.deepseek.com)
- Network: stable internet during first install
- Power: keep the charger plugged in during install

## Quick start (fresh phone)

1. Install and open Termux.
2. Grant storage access:

       termux-setup-storage

   Tap Allow on the popup.

3. Run the one-line installer:

       curl -fsSL https://raw.githubusercontent.com/lifetimerdp/deepseek-harness-android/main/boot.sh | bash

4. When prompted "API key DeepSeek:" paste your key and press Enter.
   This is the only manual input. The key is asked once and stored locally
   at /sdcard/projects/.dsh-env (mode 600).

5. Keep the charger in and wait until the installer prints its final
   "== SELESAI ==" banner (10-30 minutes depending on network).

6. Open http://127.0.0.1:3080 in your browser. Done.

Note: some installer progress messages are in Indonesian; every prompt you
need to answer is quoted exactly in this guide.

## What the installer does

1. Auto-selects the fastest reachable Termux mirror.
2. Installs base packages (curl, proot-distro, ...) non-interactively.
3. Installs an Ubuntu proot container.
4. Sets up Node.js with a working node-pty inside Ubuntu.
5. Applies the bundled fixes (fixkey.sh, fixpty.sh).
6. Installs dsh, writes the launcher, starts the web UI on port 3080.

It is idempotent: safe to re-run at any time. It only overwrites harness
files; it never deletes or touches your own project data.

## Recovering a broken Termux

If Termux ever hangs or breaks:

1. Android Settings, Apps, Termux, Clear Data.
2. Re-run the Quick start above.

Everything in /sdcard/projects survives; you only re-download the toolchain.

## Updating

Re-run the one-liner from step 3. It fetches the latest harness from this
repository and restarts the stack.

## Repository layout

    boot.sh              Bootstrap: download repo, copy harness, run installer
    tools/pasang.sh      Idempotent installer (auto mirror, non-interactive)
    tools/fixkey.sh      SSH key / permission fix
    tools/fixpty.sh      node-pty fix
    tools/build-apk.sh   APK build pipeline
    AGENTS.md            Built-in manual the agent reads (build flows, rules)

## Security

- This repository contains no API keys or secrets.
- Your key is typed once on the device and stored at
  /sdcard/projects/.dsh-env (mode 600).
- boot.sh downloads only from this GitHub repository over HTTPS.
- Never share .dsh-env or tokens. If a key leaks, rotate it on the
  DeepSeek platform.

## Troubleshooting

- "cd: /sdcard" or permission errors: run termux-setup-storage, tap Allow,
  re-run the one-liner.
- Install looks stuck: usually network speed. Keep charger in; optionally
  run termux-wake-lock in another session.
- Port 3080 already in use: an older instance is running; stop it or reboot,
  then re-run.
- "dsh: not found" after Clear Data: expected — re-run the one-liner.

## Disclaimer

Unofficial project, not affiliated with DeepSeek or Termux.
Use at your own risk; keep your API key private.
