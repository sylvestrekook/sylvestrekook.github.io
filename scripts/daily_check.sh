#!/usr/bin/env bash
# Daily site health check for sylvestrekook.github.io
# Verifies HTTP status of core pages + RSS + sitemap + robots.
# Sends PASS/FAIL to Telegram DM via bot API.
set -uo pipefail

SITE="https://sylvestrekook.github.io"
CHAT_ID="5242810094"
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"

check_url() {
  local path="$1"
  local title="$2"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "${SITE}/${path}")
  if [[ "$code" == "200" ]]; then
    echo "✅ ${title} → ${code}"
  else
    echo "❌ ${title} → ${code}"
  fi
}

RESULTS=""
RESULTS+="$(check_url "" "Home")"$'\n'
RESULTS+="$(check_url "thinking-in-probabilities-a-framework-for-financial-decisions/" "Finance post")"$'\n'
RESULTS+="$(check_url "the-attention-economy-what-tools-actually-change/" "Technology post")"$'\n'
RESULTS+="$(check_url "faith-and-reason-why-they-are-not-rivals/" "Christianity post")"$'\n'
RESULTS+="$(check_url "categories/finance/" "Finance category")"$'\n'
RESULTS+="$(check_url "categories/technology/" "Technology category")"$'\n'
RESULTS+="$(check_url "categories/christianity/" "Christianity category")"$'\n'
RESULTS+="$(check_url "about/" "About")"$'\n'
RESULTS+="$(check_url "index.xml" "RSS")"$'\n'
RESULTS+="$(check_url "sitemap.xml" "Sitemap")"$'\n'
RESULTS+="$(check_url "robots.txt" "Robots")"$'\n'

if echo "$RESULTS" | grep -q "❌"; then
  STATUS="🚨 *Sylvestre KOOK Daily Site Check — FAILURE*"
else
  STATUS="📊 *Sylvestre KOOK Daily Site Check — ALL PASS*"
fi

MSG="${STATUS}%0A%0A%60%60%60%0A$(echo "$RESULTS" | tr '\n' ' ' | sed 's/ / /g')%60%60%60%0A%0A${SITE}"

if [[ -n "$BOT_TOKEN" ]]; then
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    --data-urlencode "text=${STATUS}

${RESULTS}

${SITE}" \
    -d "parse_mode=Markdown" >/dev/null 2>&1
fi

echo "$STATUS"
echo "$RESULTS"