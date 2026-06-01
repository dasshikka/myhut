---
name: alps-hut-learning
description: Weekly read of Dasha's Alps Hut Firebase reactions → analyze patterns → update scores in file → write learnings to memory
---

You are running the weekly Alps Hut learning task for Dasha. She uses a real estate browsing tool (alps-lifestyle-scout.html) to evaluate mountain houses in the Italian Alps. Every time she saves or hides a listing, that action is silently written to a Firebase Firestore database.

Your job: read her reactions, find patterns, update the HTML file with refined scores, and write key learnings to memory.

## Step 1 — Read reactions from Firebase

Fetch this URL (Firestore REST API, test mode — no auth needed):
https://firestore.googleapis.com/v1/projects/alp-hut/databases/(default)/documents/reactions?key=AIzaSyCkksaHmCZDh7nfCMPRpjd91MLEy-kuSKU

Parse the response. Each document in `documents` array has:
- `name` field containing the listing ID (last segment after final `/`)
- `fields.action.stringValue` — last action: 'saved', 'unsaved', 'hidden', 'restored'
- `fields.listingTitle.stringValue`
- `fields.price.integerValue`
- `fields.tags.arrayValue`
- `fields.region.stringValue`
- `fields.size.integerValue`
- `fields.beds.integerValue`
- `fields.reno.stringValue`

## Step 2 — Analyze patterns

Separate listings into:
- SAVED: action = 'saved'
- HIDDEN: action = 'hidden'
- NEUTRAL: no reaction yet

Look for patterns:
- Price range: what prices are saved vs hidden?
- Region: Aosta Valley vs Val di Susa preference?
- Condition: move-in ready vs renovation — which gets saved/hidden?
- Size: minimum size that gets saved?
- Tags: 'best', 'project', 'discovery' — which category performs better?
- Renovation level: 'none', 'light', 'full' — any clear aversion?

Only draw conclusions if you have at least 3 data points in a pattern. Be honest if there isn't enough data yet.

## Step 3 — Update the HTML file

Read the current file at:
~/Documents/MyHut/alps-lifestyle-scout.html

If you found clear patterns, update scores for listings that haven't been reacted to yet. For example: if Dasha consistently hides renovation projects, lower scores of remaining renovation listings by 0.3–0.5. If she saves Aosta Valley listings, raise scores of remaining Aosta Valley listings by 0.2–0.4.

Only adjust by small increments (max ±0.8 per run). Keep scores between 1.0 and 10.0.

Also add a comment at the top of the listings array in the JS: `// Last learned: [date] — [one-line summary of what was learned]`

## Step 4 — Write to memory

Write a concise memory note summarizing:
- How many reactions total
- Key preferences discovered
- Which listings are saved vs hidden
- Any score adjustments made

Format: plain text, under 200 words. Save it somewhere you can access in future conversations about Alps Hut.

## Step 5 — Publish to live site

After updating the HTML file at ~/Documents/MyHut/alps-lifestyle-scout.html, run this bash command to trigger auto-deploy:

touch ~/Documents/MyHut/alps-lifestyle-scout.html

This signals launchd (com.myhut.autodeploy) that the file changed. The agent immediately zips and deploys to https://myhut.netlify.app using the Netlify API. Deploy log is at ~/Documents/MyHut/deploy.log — check it to confirm success.

## Step 6 — Report

After completing all steps, write a brief summary (3–5 sentences) of what you found and what you changed. This will appear as a notification in Dasha's Cowork session.
