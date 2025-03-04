#!/bin/bash

# ANSI colour codes
LIGHT_BLUE='\033[94m'
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
NC='\033[0m'

inventory_file="inventory"
inventory_list=$(grep "\[.*\]" $inventory_file | tr -d '[]') 
inventory_array=()

# echo -e "Enter filename for ${LIGHT_BLUE}NEW${NC} playbook: "
# read filename

# # Create playbook based on 'filename' variable
# touch "$filename".yml


check_inventory() {

    value=$1

    if [ -f "$inventory_file" ]; then
        echo "inventory file EXISTS:"

        while IFS= read -r line; do
            inventory_array+=("$line")
        done <<<"$inventory_list"

        declare -A group_index
        index=1
        for i in "${inventory_array[@]}"; do
            echo -e "($index) [${LIGHT_GREEN}$i${NC}]"
            group_index["$index"]="$i"
            ((index++))
        done

        
        read -p "Select a group: " group_num
        for i in "${!group_index[@]}"; do
            if [[ "$group_num" == "$i" ]]; then
                echo -e "you have selected [${LIGHT_GREEN}${group_index[$group_num]}${NC}]"

                break
            elif [[ "$group_num" -gt "${#group_index[@]}" || ! "$group_num" =~ ^[0-9]+$ ]]; then
                echo "That is not a valid number!"
                break
            fi
        done
            
    else
        echo "NO INVENTORY FILE"
    fi
}



check_inventory 
# create_play() {
#     echo -e "${LIGHT_GREEN}Define the playbook ${LIGHT_RED}[name]${NC}: "
#     read play_name

    
#     check_inventory
#     echo -e "${LIGHT_GREEN}Specify the target group (from inventory)${LIGHT_RED}[hosts]${NC}: "
#     read play_hosts

#     echo -e "${LIGHT_GREEN}Grant sudo privilages?${NC} ${LIGHT_RED}[become]${NC} : "
#     while true; do
#         read -p "Enter yes or no: " sudo_privileges

#         if [[ "$sudo_privileges" == "yes" || "$sudo_privileges" == "no" ]]; then
#             break
#         else
#             echo -e "${LIGHT_RED}Answer must be yes or no!${NC}"
#         fi
#     done
    

#     echo -e "---" >> $filename.yml
#     echo -e "- name: $play_name" >> $filename.yml
#     echo -e "  hosts: $play_hosts" >> $filename.yml
#     echo -e "  become: $sudo_privileges" >> $filename.yml
# }

# create_play

echo "[=========== RESULT ===========]"
echo -e "Playbook [${LIGHT_GREEN}$filename.yml${NC}]: "
cat $filename.yml

