



# fzf_height() {
#   local array=()
#   local input="$1"

#   # Split the input string into an array
#   IFS=$'\n' read -rd '' -a array <<< "$input"

#   local num_items=$(("${#array[@]}" + 3))
#   echo "$num_items"
# }

# get_namespace() {
#   namespaces=$(ansible-galaxy collection list | grep -vE "^#|^Collection|^---|^[[:space:]]*$" | awk -F'.' '{print $1}' | sort -u)

#   vendor_output=$(printf "%s\n" "${namespaces[@]}")
#   vendor_names=$(echo "$vendor_output" | fzf --height "$(fzf_height "$vendor_output")" --border --reverse --multi --no-info --ansi)

#   next_varaialbe=$(ansible-doc -l | grep "^$vendor_names\." | awk -F'.' '{print $1"."$2}' | sort -u)

#   collection_output=$(printf "%s\n" "${next_varaialbe[@]}" )
#   collection_names=$(echo "$collection_output"| fzf --height "$(fzf_height "$collection_output")" --border --reverse --multi --no-info --ansi)


#   next_variable_two=$(ansible-doc -l | grep "^$collection_names\." | awk '{print $1}')

#   module_output=$(printf "%s\n" "${next_variable_two[@]}" )
#   module_names=$(echo "$module_output"| fzf --height "$(fzf_height "$module_output")" --border --reverse --multi --no-info --ansi --preview "
#   ansible-doc {} | awk '/ADDED IN/ {exit} {print}'" --preview-window='bottom:30%')

#   next_variable_three=$(ansible-doc -l | grep "^$module_names " | awk '{print $1}')
  
  
#   echo "$next_variable_three"
# }

# get_namespace

# fzf_height "$vendor_output"
# fzf_height "$collection_output"
# fzf_height "$module_output"


LIGHT_RED='\e[1;31m'
NC='\e[0m'
LRB='\e[1;32m'

delete_file() {
    local filename="$1"  # Take filename as an argument

    # Animation loop for 2 seconds
    end=$((SECONDS+2))
    while [ $SECONDS -lt $end ]; do
        for dots in "●" "○" "●" "○" "●" "○"; do
            echo -ne "\r${LIGHT_RED}Deleting File - ${dots}${NC}"  # \r keeps it on the same line
            sleep 0.2
        done
    done

    # Remove the file
    rm -f "$filename.yml"

    # Clear the animation text and replace it with "FILE DELETED!"
    echo -ne "\r${LRB}FILE DELETED! - ●${NC}      \n"  # Overwrites old text
}



# Example usage:
delete_file "yourfile"  # Replace with actual filename

#ansible-doc "$next_variable_three"

# selection=$(printf "%s\n" "${options[@]}" | fzf --preview='
#   reference="'"$extra"'" # Use the global extra variable
#   echo "Processing $reference with {}"
# ')