# deepseek-harness-android

**DeepSeek Harness di HP** — menjalankan agen DeepSeek (dsh) di Android:
Termux + proot Ubuntu + node-pty asli, tanpa root.

## Butuh
- Android + Termux (pasang dari F-Droid, bukan Play Store)
- API key DeepSeek

## Install (HP baru)
1. Buka Termux: `termux-setup-storage` → Izinkan
2. Satu baris:

curl -fsSL https://raw.githubusercontent.com/lifetimrdp/deepseek-harness-android/main/boot.sh | bash

3. Saat ditanya `API key DeepSeek:` → ketik key + Enter (satu-satunya input manual).
4. Colok charger, tunggu `== SELESAI ==`, lalu buka http://127.0.0.1:3080

Aman diulang; tidak menghapus isi /sdcard/projects (hanya menimpa file harness).

## Jika Termux rusak
Settings → Apps → Termux → Clear Data, lalu ulangi Install.
Semua aset proyek aman di /sdcard/projects.

## Keamanan
Repo ini TIDAK berisi API key. Key diketik manual saat install dan
disimpan di /sdcard/projects/.dsh-env (chmod 600).

## Isi repo
- `boot.sh` — bootstrap: unduh repo, salin harness, jalankan installer
- `tools/pasang.sh` — installer idempoten (mirror Indonesia otomatis)
- `tools/fixkey.sh`, `tools/fixpty.sh` — perbaikan SSH & node-pty
- `tools/build-apk.sh` — jalur build APK
- `AGENTS.md` — manual bawaan harness (cara build APK, dll.)
