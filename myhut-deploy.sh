#!/bin/bash
# MyHut → Netlify auto-deploy
# Triggered by launchd when ~/Documents/MyHut/alps-lifestyle-scout.html changes

NETLIFY_TOKEN="nfp_7HFnQAAKdPJatQF4W29mdtPceDEtvFQGf909"
SITE_ID="cbbf99eb-7160-48ad-be2c-fa972c9c7518"
HTML_FILE="$HOME/Documents/MyHut/alps-lifestyle-scout.html"
LOG_FILE="$HOME/Documents/MyHut/deploy.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deploy triggered" >> "$LOG_FILE"

if [ ! -f "$HTML_FILE" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: HTML file not found" >> "$LOG_FILE"
  exit 1
fi

# Step 1: Compute SHA1 of the file
FILE_SHA=$(openssl sha1 "$HTML_FILE" | awk '{print $2}')

# Step 2: Create deploy with file manifest
DEPLOY_RESPONSE=$(curl -s \
  -X POST \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"files\": {\"/index.html\": \"$FILE_SHA\"}}" \
  "https://api.netlify.com/api/v1/sites/$SITE_ID/deploys")

DEPLOY_ID=$(echo "$DEPLOY_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null)
REQUIRED=$(echo "$DEPLOY_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('required',[])))" 2>/dev/null)

if [ -z "$DEPLOY_ID" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Could not create deploy" >> "$LOG_FILE"
  exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deploy created: $DEPLOY_ID (required uploads: $REQUIRED)" >> "$LOG_FILE"

# Step 3: Upload file only if Netlify doesn't already have it cached
if [ "$REQUIRED" -gt "0" ]; then
  UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X PUT \
    -H "Authorization: Bearer $NETLIFY_TOKEN" \
    -H "Content-Type: text/html; charset=utf-8" \
    --data-binary @"$HTML_FILE" \
    "https://api.netlify.com/api/v1/deploys/$DEPLOY_ID/files/index.html")

  HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -1)

  if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "201" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR uploading file: HTTP $HTTP_CODE" >> "$LOG_FILE"
    exit 1
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] File uploaded OK" >> "$LOG_FILE"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] File already cached by Netlify — no upload needed" >> "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS — deployed to https://myhut.netlify.app" >> "$LOG_FILE"
