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


# create_play
echo "Select one:"


#!/bin/bash

LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
NC='\033[0m'

# Define options (including "Exit" as the last option)
options=("name" "apt" "doc" "Done")
selected_options=()

while true; do

    # change the colour of the option

    # Show fzf with multi-selection enabled
    selection=$(printf "%s\n" "${options[@]}" | fzf --height 6 --border --reverse --multi --no-info)
    


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
        done
    
        break
    fi

done


