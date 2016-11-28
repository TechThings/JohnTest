#!/bin/bash

# Trigger Production build on Bitrise.io based on the passed in tag
echo "Trigerring production build for tag: $1"

SLUG="30a852294581843f"
API_TOKEN="jXyDaKnhSi-U7tLgxy9HLg"
payload="{\"hook_info\":{\"type\":\"bitrise\",\"api_token\":\"$API_TOKEN\"},\"build_params\":{\"tag\":\"$1\",\"workflow_id\":\"production\"}}"

curl -X POST "https://www.bitrise.io/hook/$SLUG" --data-urlencode "payload=$payload"