#!/bin/bash

# CONFIG
# https://github.com/AMP-SCZ/db-query-collection/tree/mri_team_count
REPO="AMP-SCZ/db-query-collection"
BRANCH="mri_team_count"


TOKEN_FILE='.token'
# Load GitHub token from .token file
if [ ! -f "$TOKEN_FILE" ]; then
    echo "❌ Token file not found at $TOKEN_FILE"
    exit 1
fi

GITHUB_TOKEN=$(cat "$TOKEN_FILE")
echo $GITHUB_TOKEN
LAST_SHA_FILE="tmp_last_sha.txt"
WORKDIR="/data/predict1/home/kcho/software/db-query-collection"

echo curl -H \""Authorization: token $(cat .token)\"" https://api.github.com/user
curl -H "Authorization: token $(cat .token)" https://api.github.com/user

echo '**'
echo $(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$REPO/commits/$BRANCH \
    )
echo '**'

# Get latest commit SHA from GitHub
LATEST_SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$REPO/commits/$BRANCH \
    | jq -r '.sha')

echo $LATEST_SHA

echo hahah $LAST_SHA
# Get previously known SHA
if [ -f "$LAST_SHA_FILE" ]; then
    LAST_SHA=$(cat "$LAST_SHA_FILE")
else
    LAST_SHA=""
fi

# Compare
if [ "$LATEST_SHA" != "$LAST_SHA" ]; then
    echo "🔁 New commit detected: $LATEST_SHA"
    #cd "$WORKDIR"
    #git pull origin $BRANCH
    #./mri_team_count/update_and_execute_view_creation.sh
    #echo "$LATEST_SHA" > "$LAST_SHA_FILE"
else
    echo "✅ No new changes. Latest SHA: $LATEST_SHA"
fi

