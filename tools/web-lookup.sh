#!/system/bin/bash
# web-lookup.sh <query> — pencarian web tanpa API key (endpoint publik).
set -uo pipefail
q="$*"
[ -z "$q" ] && { echo "usage: web-lookup.sh <query>"; exit 1; }
UA="Mozilla/5.0 (X11; Linux aarch64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
enc=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$q")
echo "== WIKIPEDIA =="
curl -s --max-time 8 "https://id.wikipedia.org/w/api.php?action=query&list=search&srsearch=${enc}&format=json" | python3 -c '
import json,sys,re
try:
    d=json.load(sys.stdin)
    for r in d.get("query",{}).get("search",[])[:5]:
        t=r.get("title","")
        sn=re.sub("<[^>]+>","",r.get("snippet",""))
        print("- "+t+" | https://id.wikipedia.org/wiki/"+t.replace(" ","_")+" | "+sn)
except Exception:
    print("(wikipedia gagal)")
'
echo "== DUCKDUCKGO =="
curl -s --max-time 8 -A "$UA" "https://html.duckduckgo.com/html/?q=${enc}" | python3 -c '
import sys,re,html
t=sys.stdin.read()
titles=re.findall(r"class=\"result__a\"[^>]*>(.*?)</a>",t,re.S)
urls=re.findall(r"class=\"result__url\"[^>]*>(.*?)</a>",t,re.S)
if not titles:
    print("(ddg gagal)")
else:
    for i,x in enumerate(titles[:5]):
        u=urls[i].strip() if i<len(urls) else ""
        x=html.unescape(re.sub(r"<[^>]+>","",x)).strip()
        print("- "+x+" | "+u)
'
