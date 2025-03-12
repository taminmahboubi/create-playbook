# # create an associtive array
# declare -A my_array

# # add elements in associative array
# my_array["1"]="first"
# my_array["2"]="second"
# my_array["3"]="third"

# for key in "${!my_array[@]}"; do
#     echo "$key: ${my_array[$key]}"
# done

# #printf "%s\n" "${!group_index[@]}" | sort -n

# printf "%s\n" "${!my_array[@]}" | sort -n
# # print elements in single line
# echo "${my_array[@]:0:3}"


# filename=$(dialog --inputbox "Enter a file name:" 10 40 2>&1 >/dev/tty)
# clear

# create_play() {
#     play_name=$(dialog --inputbox "Enter Play-[name]:" 10 40 --nocancel 2>&1 >/dev/tty)

#     play_hosts=$(dialog --inputbox "Enter groups (from inventory)-[hosts]:" 10 40 2>&1 >/dev/tty --nocancel)
#     # check_inventory
#     # hosts_num="${#selected_groups[@]}"
#     # play_hosts="${selected_groups[@]:0:$hosts_num}"

#     sudo_privileges=$(dialog --inputbox "Grant sudo privileges? (yes/no)-[become]:" 10 40 2>&1 >/dev/tty --nocancel)
#     # while true; do
#     #     read -p "> " sudo_privileges

#     #     if [[ "$sudo_privileges" == "yes" || "$sudo_privileges" == "no" ]]; then
#     #         break
#     #     else
#     #         echo -e "${LIGHT_RED}Answer must be yes or no!${NC}"
#     #     fi
#     # done    
#     clear

#     # echo -e "---" >> $filename.yml
#     # echo -e "- name: $play_name" >> $filename.yml
#     # echo -e "  hosts: $play_hosts" >> $filename.yml
#     # echo -e "  become: $sudo_privileges" >> $filename.yml
# }

#!/bin/bash
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
LGB='\e[102m'
NC='\033[0m'

aptlist=$(ansible-doc apt | grep '^-\s' | grep -v 'name:' | cut -d ' ' -f 2)


# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${LIGHT_RED}fzf is not installed.{$NC} Installing now..."

    # Detect package manager and install fzf
    if [[ -f /etc/debian_version ]]; then
        sudo apt update && sudo apt install -y fzf
    elif [[ -f /etc/redhat-release ]]; then
        sudo yum install -y fzf
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm fzf
    elif command -v brew &> /dev/null; then
        brew install fzf
    else
        echo "Unsupported system. Please install fzf manually."
        exit 1
    fi

    echo -e "${LIGHT_GREEN}fzf installed successfully!${NC}"
else
    echo -e "${LGB}fzf is already installed${NC}"
fi

# create_play
echo "Select one:"





new_array=()

select_task() {
    local arr_name="$1"
    local -n options="$arr_name"

    options+=("Done")
    selected_options=()

    while true; do

        # change the colour of the option

        # Show fzf with multi-selection enabled
        selection=$(printf "%s\n" "${options[@]}" | fzf --height 10 --border --reverse --multi --no-info)
        


        if [[ -n "$selection" && "$selection" != "Done" ]]; then
            # check each selected item
            for item in $selection; do
                already_selected=false

                for selected in "${selected_options[@]}"; do
                    if [[ "$selected" == "$item" ]]; then
                        already_selected=true
                        break
                    fi
                done

                if $already_selected; then
                    echo -e "${LIGHT_RED}Error: '$item' is already selected!${NC}"
                    continue
                else
                    selected_options+=("$item")
                    echo -e "You selected: ${LIGHT_GREEN}$item${NC}"
                    continue
                fi

            done
        elif [[ "${#selected_options[@]}" -eq 0 && "$selection" == "Done" ]]; then
            echo -e "${LIGHT_RED}Error: you must choose at least one!${NC}"
            continue
        elif [[ "$selection" == *"Done"* ]]; then # If "Exit" is selected, break the loop
            echo "Selected:"

            for i in "${selected_options[@]}"; do
                echo -e "${LIGHT_GREEN}$i${NC}"
                new_array+=("$i")
            done
             
            break
        fi
    done
   
}

my_array=("name" "apt" "service")
select_task aptlist


echo "new_array:"
for i in "${new_array[@]}"; do
    echo -e "${LIGHT_GREEN}$i${NC}"
done






get_module() {
    module_param="$1"

    # command ansible-doc apt | awk '/^- update_cache/{flag=1} flag && !printed; /type:/{if(flag){print; printed=1; exit}}'
    #options_description=$(ansible-doc apt | awk -v param="$module_param" '$0 ~ "^- " param {flag=1} flag && !printed; /type:/ {if(flag){printed=1; exit}}')
    # command ansible-doc apt | sed '/^- update_cache/,$!d' | awk '/^  /{print} /type:/{exit}'
    options_description=$(ansible-doc apt | sed "/^- $module_param/,/type:/!d; /^- $module_param/d; /type:/q")

    echo "$options_description"

}

declare -A options_dict  # Declare an associative array

# Extract options section
#options_text=$(ansible-doc apt | awk '/OPTIONS \(= is mandatory\):/{flag=1; next} /ATTRIBUTES:/{flag=0} flag')
options_text=$(ansible-doc apt | awk '/^RETURN VALUES:/ {exit} {print}' | grep '^-\s' | grep -v 'name:' | cut -d ' ' -f 2)
some_array=()

# # Populate associative array
# while IFS= read -r line; do
#     if [[ $line == "- "* ]]; then
#         key=${line#"- "}  # Remove leading '- ' to get the key
#         current_value=$(get_module "$key")
#         options_dict[$key]="$current_value"
#     fi
# done <<< "$options_text"


while IFS= read -r line; do
   some_array+=("$line")
done <<< "$options_text"

# # store the param of each module to the module
for key in "${some_array[@]}"; do
    current_value=$(get_module "$key")
    options_dict[$key]="$current_value"
done



echo -e "${LIGHT_RED}DEBUG:${NC} for loop done"



