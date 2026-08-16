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
