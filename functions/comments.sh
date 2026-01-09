get_comments() {
  curl -s "$BASE_URL/comments?a_id=$1"
}
