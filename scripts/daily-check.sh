#!/bin/bash
# ============================================================
# 纳米卷文献每日检查脚本
# 搜索 arXiv + Crossref + Semantic Scholar 的最新纳米卷论文
# 每天由 cron 自动执行
# ============================================================

cd "$(dirname "$0")/.." || exit 1

TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "1 day ago" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || echo "$TODAY")
NEW_PAPERS_FILE="papers/new_${TODAY}.md"
ALL_PAPERS_JSON="papers/papers.json"
ARXIV_BASE="https://export.arxiv.org/api/query"

echo "=== 纳米卷文献每日检查 ==="
echo "日期: $TODAY"
echo ""

# 语义搜索词 (中英文)
QUERIES=(
  "nanoscroll"
  "carbon nanoscroll"
  "MoS2 nanoscroll"
  "oxide nanoscroll"
  "nanocoil"
  "rolled-up 2D material"
  "纳米卷"
)

NEW_COUNT=0

# ---- 1. arXiv 搜索 ----
echo "--- arXiv ---"
for q in "${QUERIES[@]}"; do
  sleep 4  # arXiv rate limit: ~1 req/3s
  results=$(curl -s --max-time 15 "$ARXIV_BASE?search_query=all:$(echo "$q" | sed 's/ /+/g')&sortBy=submittedDate&sortOrder=descending&max_results=10" 2>/dev/null)
  
  # Parse XML with grep (fast, no XML lib required)
  titles=$(echo "$results" | grep -A1 '<title>' | grep -v '<title>' | grep -v '^--$' | sed 's/^ *//' | head -5)
  ids=$(echo "$results" | grep '<id>http' | sed 's/.*<id>//;s/<.*//' | head -5)
  dates=$(echo "$results" | grep '<published>' | sed 's/.*<published>//;s/T.*//' | head -5)
  
  i=0
  for id in $ids; do
    title_line=$(echo "$titles" | sed -n "$((i+1))p")
    date_line=$(echo "$dates" | sed -n "$((i+1))p")
    # Check if paper is from today or yesterday
    if [ "$date_line" = "$TODAY" ] || [ "$date_line" = "$YESTERDAY" ]; then
      echo "NEW: $title_line"
      echo "  $id"
      echo "  Date: $date_line"
      NEW_COUNT=$((NEW_COUNT + 1))
    fi
    i=$((i + 1))
  done
done

# ---- 2. Crossref 搜索 ----
echo ""
echo "--- Crossref ---"
for q in "${QUERIES[@]}"; do
  sleep 1
  cr_results=$(curl -s --max-time 15 "https://api.crossref.org/works?query=$q&sort=published&order=desc&rows=5&filter=from-pub-date:$YESTERDAY" 2>/dev/null)
  if [ -n "$cr_results" ]; then
    echo "$cr_results" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data.get('message',{}).get('items',[]):
        t = item.get('title',[''])[0]
        d = item.get('created',{}).get('date-parts',[['']])[0]
        doi = item.get('DOI','')
        if d and t:
            print(f'NEW: {t}')
            print(f'  DOI: {doi}')
            print(f'  Date: {d}')
    found = len(data.get('message',{}).get('items',[]))
    if found > 0: print(f'  (found {found} results for query: $q)')
except: pass
" 2>/dev/null
  fi
done

# ---- 3. Summary ----
echo ""
echo "=== 检查完成 ==="
if [ "$NEW_COUNT" -eq 0 ]; then
  echo "未发现新的纳米卷相关文献。"
else
  echo "发现 $NEW_COUNT 篇新文献！"
fi
