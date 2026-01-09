#!/bin/bash

get_articles() {
  curl -s "$BASE_URL/articles"
}

get_single_article() {
  curl -s "$BASE_URL/articles/$1"
}

publish_article() {
  curl -s -X POST "$BASE_URL/articles" \
    -H "api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"article\": {
        \"title\": \"$1\",
        \"body_markdown\": \"$2\",
        \"tags\": \"$3\",
        \"published\": true
      }
    }"
}

update_article() {
  local id="$1"
  local title="$2"
  local body="$3"

  payload=$(jq -n \
    --arg title "$title" \
    --arg body "$body" \
    '{
      article: {
        title: $title,
        body_markdown: $body
      }
    }')

  curl -s -X PUT "$BASE_URL/articles/$id" \
    -H "api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload"
}


delete_article() {
  curl -s -X DELETE "$BASE_URL/articles/$1" \
    -H "api-key: $API_KEY"
}

get_my_articles() {
  curl -s "$BASE_URL/articles/me" \
    -H "api-key: $API_KEY"
}
