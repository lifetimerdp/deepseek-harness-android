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

## Build Android — peta otonom (proyek NASI)

Lingkungan (sudah terpasang manual oleh pengguna; JANGAN instal apa pun):
- proot ubuntu: JDK 17, SDK 36 + build-tools 36.0.0 (aapt2 aarch64), Gradle 8.13.
- `android.aapt2.fromMaven=false` sudah global; local.properties: `sdk.dir=/opt/android-sdk`.
- Pin versi: AGP 8.9.1 + Kotlin 2.1.x; TANPA Gradle wrapper.

ATURAN OTONOMI (menggeser aturan lama yang menyuruh meminta pengguna):
- Agen TIDAK meminta pengguna menjalankan build — agen menjalankan sendiri.
- Gradle sinkron (<60 dtk) lewat `bash tools/gradle-proot.sh <args>`.
- Build/unduh apa pun: `bash tools/gradle-build.sh start <args>` dari direktori
  proyek — kembali SEKETIKA karena build jalan di latar.
- Polling: `bash tools/gradle-build.sh status` (seketika). RUNNING → kerjakan hal
  berguna lain lalu poll lagi; SUCCESS → lanjut; FAILED →
  `bash tools/gradle-build.sh log 80`, perbaiki kode, `start` lagi.
- Gradle resumable & cache: error jaringan = `start` task yang sama lagi.
- Skrip menolak menimpa build RUNNING; jangan akali dengan nohup manual.
- Sebelum build besar pertama: `termux-wake-lock` (host) agar proses latar tidak
  dibunuh Android.
- STATUS=CRASHED → proses mati tanpa marker (OOM/proot dibunuh): `log 80` untuk
  diagnosa, perbaiki, `start` lagi.

## Kekhasan harness run_code (JANGAN rediscover — hemat token)

- Channel output run_code flaky saat operasi panjang: JANGAN andalkan stdout
  inline; hasil build dibaca dari FILE log lewat Read/tail (nasi/buildN.log atau
  .build/build.log), persis peta otonom.
- Runner berbasis JS: backtick (`) dan ''' di konten Kotlin merusak template
  literal ("Expected ';'"). Tulis file berisi karakter itu lewat Bash heredoc
  quoted ('EOF'), jangan string inline JS.
- Edit wajib Read file yang sama tepat sebelumnya; edit beruntun ke file sama
  kena guard "file changed since read" → tulis ulang penuh lewat Bash lebih aman.
- Jangan buat file ekor bantu (_bN.tail); tail langsung dari buildN.log.
- Higiene log: setelah SUCCESS hapus buildN.log lama, sisakan 3 terakhir.
