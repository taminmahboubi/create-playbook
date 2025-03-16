options=("file1" "file2")
extra="more info"

selection=$(printf "%s\n" "${options[@]}" | fzf --preview='
  reference="'"$extra"'" # Use the global extra variable
  echo "Processing $reference with {}"
')

echo "$selection"