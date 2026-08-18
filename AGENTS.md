# AGENTS.md - SOP dsh
## Lingkungan
- Host: Termux Android
- Agent jalan di proot Ubuntu
- Workspace: /sdcard/projects
- Tools: /sdcard/projects/tools
- API: source /sdcard/projects/.dsh-env
## Aturan
1. cd /sdcard/projects dulu.
2. Jangan ubah tools/ tanpa perintah.
3. File baru masuk workspace.
4. Baca sebelum edit; edit minimal.
5. Uji risiko dengan echo/dry-run.
6. Bocorkan rahasia = dilarang.
7. Ragu = tanya, jangan tebak.
## Build APK
- bash tools/build-apk.sh <Dir> <Out.apk>
- android.jar: tools/android.jar
- JDK/aapt/dx/zipalign/apksigner: Termux
## dsh
- UI: http://127.0.0.1:3080
- Config: /root/.dsh/cordis.patch.yml
- SSH: /root/.ssh/id_ed25519
## Gaya
- Ringkas, konkret, bhs Indonesia.
- Error: tempel apa adanya + 1 perintah.

## Tool failure protocols (Android/proot environment)

- Pencarian web: sekali per sesi jalankan `bash` -> `printenv DEEPSEEK_API_KEY`.
  Jika kosong/tidak ada: JANGAN panggil `web_search`; gunakan
  `bash tools/web-lookup.sh "<query>"` untuk semua pencarian sesi itu.
  Jika terisi: gunakan `web_search`; bila error credentials, pindah ke web-lookup.sh.
- `job_output` -> "unknown job" dan `job_list` kosong: NORMAL untuk subagent
  latar belakang; hasil tiba otomatis lewat injeksi `subagent-settled`.
  Cek `list_agents`; bila running, tunggu (`sleep 10`) atau kerjakan hal lain.
  Jangan retry `job_output` lebih dari 2 kali.

## Konvensi tambahan (semua model)

- Hanya `run_code` yang callable langsung; semua tool lain (`bash`, `read`,
  `ask_user_question`, `subagent`, dll.) dipanggil dari dalam `run_code`.
- Jika tool interaktif gagal dirender, ajukan pertanyaan sebagai teks biasa
  agar pengguna tetap bisa menjawab.

## Build Android (proyek NASI)

- Toolchain lengkap (JDK 17, SDK 36, build-tools 36, Gradle 8.13) ada di
  proot ubuntu. JANGAN pasang apa pun di Termux maupun proot.
- Semua perintah Gradle dijalankan lewat `bash tools/gradle-proot.sh <args>`
  dari direktori proyek (contoh: `bash tools/gradle-proot.sh assembleDebug`).
- local.properties proyek: `sdk.dir=/opt/android-sdk` (path di dalam proot).
- Build pertama menarik dependensi Maven (±0,5–1 GB) di dalam proot; bila
  terputus, ulangi perintah yang sama.
