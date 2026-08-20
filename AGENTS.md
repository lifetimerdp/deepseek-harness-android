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

## Full debug TANPA adb (mode default)

Sensor pengganti (tanpa adb, tanpa emulator):
1. JVM: unit test + Robolectric, termasuk skenario UI Compose di JVM
   (createComposeRule di test lokal — didukung resmi). Jalankan lewat
   `gradle-build.sh start testDebugUnitTest`.
2. Self-diagnostic app (build debug): UncaughtExceptionHandler global
   menulis crash-<ts>.log; trace navigasi/aksi menulis trace.log —
   semua ke /sdcard/projects/.build/ (izin akses file diminta sekali
   saat pertama run). Agen MEMBACA file itu sebagai pengganti logcat/ui.
Metode: tiap bug = failing test → perbaiki → hijau (regression permanen).
Bug runtime dibaca dari crash/trace setelah pengguna memakai app normal.
Tanpa adb TIDAK bisa: install & tap otomatis di perangkat → instalasi =
pengguna tap APK sekali per build. device.sh tetap opsional bila adb ter-pair.

## Pairing permanen + reconnect otonom + full debug ADB

- Pairing PERMANEN (kunci tersimpan di kedua sisi) — TIDAK ADA pairing ulang,
  termasuk setelah restart/reboot.
- Reconnect OTONOM tanpa manusia: `device.sh connect` = alamat tersimpan →
  mDNS → scan port listener /proc/net/tcp. Biasanya DEVICE=READY sendiri
  setelah reboot. Jalankan saat mulai sesi dan setiap kali koneksi putus.
- Worst case jarang: toggle Wireless debugging OFF setelah reboot → pengguna
  menyalakan sekali (satu tap, tanpa kode), lalu connect otonom lagi.
- Loop full debug ADB: install (adb sendiri) → launch → ui → skenario
  tap/text/key fitur-per-fitur → log saat anomali → NASI-BUGS.md → perbaiki →
  build → install → verifikasi ulang skenario gagal. Bug logika wajib jadi
  regression test (testDebugUnitTest).

## Definition of Done — QA otonom WAJIB (semua proyek, tanpa diminta)

Pengguna TIDAK perlu menyebut adb/testing/audit. Sebelum melaporkan hasil apa
pun ke pengguna, agen WAJIB melewati gerbang QA ini sendiri:
1. Build hijau (pakai peta build; catat warning).
2. Audit statis mandiri: baca ulang diff — null-safety, lifecycle, izin,
   kebocoran memori, ANR, edge case input.
3. Test JVM hijau (testDebugUnitTest / suite proyek); setiap bug logika yang
   diperbaiki WAJIB meninggalkan regression test baru.
4. E2E: Android = `device.sh connect` (otonom) → install → launch → skenario
   SEMUA fitur via ui/tap/text/key → `log` bersih. Web app = jalankan server
   lokal, probe semua endpoint/halaman, cek status & konten.
5. BUGS.md (NASI-BUGS.md untuk nasi): temuan dicatat → diperbaiki → build →
   install → verifikasi ulang skenario gagal → ditutup. Loop sampai nol bug
   terbuka.
6. Baru lapor ke pengguna: ringkasan fitur + hasil QA + langkah pakai.
   Jangan pernah meminta pengguna menjalankan perintah teknis.
Bila pengguna melaporkan "ada bug" tanpa daftar → langsung jalankan loop full
debug di atas; temukan sendiri lewat sensor, jangan menunggu rincian.

## QA cepat & tidak mengganggu pengguna (WAJIB)

Masalah lama: loop LLM per-tap = menit per gerakan; E2E perangkat menyita layar.
1. LATAR BELAKANG (default): test JVM (unit+Robolectric+Compose-JVM) via
   `qa.sh bg`; agen poll log; pengguna BEBAS memakai HP selama itu.
2. E2E perangkat = ONE-SHOT: skenario ditulis sekali (eksplorasi LLM boleh
   hanya saat mengarang) lalu disimpan sebagai tools/scenarios/*.sh (urutan
   device.sh tap/text/key + assert ui/log). Regresi = satu perintah, baca
   hasil sekali. DILARANG loop LLM per-tap untuk regresi.
3. Sebelum E2E: `qa.sh fast` (animasi 0) + cek `qa.sh idle`; bila pengguna
   aktif → tunda atau minta izin SATU kalimat. E2E singkat; layar dikembalikan.
4. Build Gradle berat: saat charging bila memungkinkan.
