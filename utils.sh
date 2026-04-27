assert_signetchallenge_match() {
  local conf_file=~/.bitcoin/bitcoin.conf
  local challenge_file=~/.bitcoin/SIGNETCHALLENGE.txt

  # Extract from bitcoin.conf (ignores comments)
  local conf_challenge
  conf_challenge=$(grep -E '^\s*signetchallenge\s*=' "$conf_file" | sed -E 's/^\s*signetchallenge\s*=\s*//;s/\s*$//')

  # Read the file content
  local file_challenge
  file_challenge=$(<"$challenge_file")

  if [[ -z "$conf_challenge" ]]; then
    echo "❌ 'signetchallenge' not found or empty in $conf_file"
    return 1
  fi

  if [[ -z "$file_challenge" ]]; then
    echo "❌ SIGNETCHALLENGE.txt is empty"
    return 1
  fi

  if [[ "$conf_challenge" != "$file_challenge" ]]; then
    echo "❌ Mismatch between bitcoin.conf and SIGNETCHALLENGE.txt:"
    echo "    bitcoin.conf:        $conf_challenge"
    echo "    SIGNETCHALLENGE.txt: $file_challenge"
    return 1
  fi

  echo "✔ signetchallenge matches in both files."
  return 0
}
