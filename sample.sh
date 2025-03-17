fzf_height() {
  local array=()
  local input="$1"

  # Split the input string into an array
  IFS=$'\n' read -rd '' -a array <<< "$input"

  local num_items=$(("${#array[@]}" + 3))
  echo "$num_items"
}

collection=$(ansible-galaxy collection list | grep -vE "^#|^Collection|^---|^[[:space:]]*$" | awk -F'.' '{print $1}' | sort -u)

vendor_output=$(printf "%s\n" "${collection[@]}")
vendor_names=$(echo "$vendor_output" | fzf --height "$(fzf_height "$vendor_output")" --border --reverse --multi --no-info --ansi)

next_varaialbe=$(ansible-doc -l | grep "^$vendor_names\." | awk -F'.' '{print $1"."$2}' | sort -u)

collection_output=$(printf "%s\n" "${next_varaialbe[@]}" )
collection_names=$(echo "$collection_output"| fzf --height "$(fzf_height "$collection_output")" --border --reverse --multi --no-info --ansi)

fzf_height "$vendor_output"
fzf_height "$collection_output"


# selection=$(printf "%s\n" "${options[@]}" | fzf --preview='
#   reference="'"$extra"'" # Use the global extra variable
#   echo "Processing $reference with {}"
# ')