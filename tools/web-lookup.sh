#!/system/bin/bash
# web-lookup.sh <query> — pencarian web tanpa API key (multi-sumber, endpoint publik).
set -uo pipefail
q="$*"
[ -z "$q" ] && { echo "usage: web-lookup.sh <query>"; exit 1; }
UA="Mozilla/5.0 (X11; Linux aarch64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
enc=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$q")

wiki() {
curl -s --compressed --max-time 6 "https://$1.wikipedia.org/w/api.php?action=query&list=search&srsearch=${enc}&format=json" | python3 -c '
import json,sys,re
lang=sys.argv[1]
try:
    d=json.load(sys.stdin)
    n=0
    for r in d.get("query",{}).get("search",[])[:5]:
        t=r.get("title","")
        sn=re.sub("<[^>]+>","",r.get("snippet",""))
        print("- "+t+" | https://"+lang+".wikipedia.org/wiki/"+t.replace(" ","_")+" | "+sn); n+=1
    if n==0: print("(kosong)")
except Exception:
    print("(gagal)")
' "$1"
}
echo "== WIKIPEDIA (en) =="; wiki en
echo "== WIKIPEDIA (id) =="; wiki id

echo "== DUCKDUCKGO LITE =="
curl -s --compressed --max-time 6 -A "$UA" "https://lite.duckduckgo.com/lite/?q=${enc}" | python3 -c '
import sys,re,html
t=sys.stdin.read()
pairs=re.findall(r"<a[^>]+href=\"(https?://[^\"]+)\"[^>]*>(.*?)</a>",t,re.S)
seen=set(); n=0
for u,x in pairs:
    x=html.unescape(re.sub(r"<[^>]+>","",x)).strip()
    if not x or len(x)<8 or "duckduckgo.com" in u or u in seen: continue
    seen.add(u); print("- "+x+" | "+u); n+=1
    if n>=5: break
if n==0: print("(gagal)")
'

echo "== HACKER NEWS =="
curl -s --compressed --max-time 6 "https://hn.algolia.com/api/v1/search?query=${enc}&hitsPerPage=5" | python3 -c '
import json,sys
try:
    d=json.load(sys.stdin); n=0
    for h in d.get("hits",[]):
        t=(h.get("title") or "").strip()
        if not t: continue
        u=h.get("url") or ("https://news.ycombinator.com/item?id="+str(h.get("objectID")))
        print("- "+t+" | "+u); n+=1
    if n==0: print("(kosong)")
except Exception:
    print("(gagal)")
'

echo "== STACKOVERFLOW =="
curl -s --compressed --max-time 6 "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=${enc}&site=stackoverflow&pagesize=5" | python3 -c '
import json,sys,html,re
try:
    d=json.load(sys.stdin); n=0
    for it in d.get("items",[]):
        t=html.unescape(re.sub(r"<[^>]+>","",it.get("title","")))
        print("- "+t+" | "+it.get("link","")); n+=1
    if n==0: print("(kosong)")
except Exception:
    print("(gagal)")
'
