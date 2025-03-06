#!/bin/bash

# ANSI colour codes
LIGHT_BLUE='\033[94m'
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
NC='\033[0m'

inventory_file="inventory"
inventory_list=$(grep "\[.*\]" $inventory_file | tr -d '[]') 
reversed_inventory=()
inventory_array=()
selected_groups=()

echo -e "Enter filename for ${LIGHT_BLUE}NEW${NC} playbook: "
read filename

# Create playbook based on 'filename' variable
touch "$filename".yml


declare -A group_index
index=1

check_inventory() {
    if [ -f "$inventory_file" ]; then
        echo -e "${LIGHT_GREEN}inventory${NC} file EXISTS"

        mapfile -t inventory_array <<<"$inventory_list"

        # Populate group_index ONCE
        declare -gA group_index  # Make it global
        index=1
        for i in "${inventory_array[@]}"; do
            group_index["$index"]="$i"
            ((index++))
        done

        print_inventory

    else
        echo "NO INVENTORY FILE"
    fi
    declare -g inventory_length=${#group_index[@]}
}

print_inventory() {
    for key in $(printf "%s\n" "${!group_index[@]}" | sort -n); do
        echo -e "$key: ${group_index[$key]}"
    done
    
    select_group
}

remove_group() { 
    id=$1

    if [[ -v group_index[$id] ]]; then
        unset "group_index[$id]"
        
        # Length updated
        inventory_length=${#group_index[@]}

        # Rebuild ordered list to renumber
        declare -A new_group_index
        index=1
        for key in $(printf "%s\n" "${!group_index[@]}" | sort -n); do
            new_group_index["$index"]="${group_index[$key]}"
            ((index++))
        done

        # Replace the old array with the new one
        group_index=()
        for key in "${!new_group_index[@]}"; do
            group_index["$key"]="${new_group_index[$key]}"
        done

    else
        echo "Group ID not found."
    fi
}

select_group() {

    has_groups=true

    if [[ -z "${!group_index[@]}" ]]; then
        echo -e "${LIGHT_RED}NO GROUPS REMAINING!${NC}"
        has_groups=false
    else
         while $has_groups; do
            read -p "Select a group (type 'done' when finished): " group_num

            if [[ "$group_num" =~ ^[0-9]+$ && -v group_index[$group_num] ]]; then
                echo -e "You have selected [${LIGHT_GREEN}${group_index[$group_num]}${NC}]"
                send_groups "${group_index[$group_num]}"
                remove_group "$group_num"
                print_inventory
                break
            elif [[ "$group_num" == "done" ]]; then
                echo -e "${LIGHT_GREEN}Done${NC}"
                send_groups "${group_index[$group_num]}"
                break
            else
                echo "That is not a valid number!"
            fi
        done
    fi


}

send_groups() {
    group=$1

    selected_groups+=("$1")
}




create_play() {
    echo -e "${LIGHT_GREEN}Define the playbook ${LIGHT_RED}[name]${NC}: "
    read play_name

    
    echo -e "${LIGHT_GREEN}Specify the target group (from inventory)${LIGHT_RED}[hosts]${NC}: "
    check_inventory
    hosts_num="${#selected_groups[@]}"
    play_hosts="${selected_groups[@]:0:$hosts_num}"


    echo -e "${LIGHT_GREEN}Grant sudo privilages?${NC} ${LIGHT_RED}[become]${NC} : "
    while true; do
        read -p "Enter yes or no: " sudo_privileges

        if [[ "$sudo_privileges" == "yes" || "$sudo_privileges" == "no" ]]; then
            break
        else
            echo -e "${LIGHT_RED}Answer must be yes or no!${NC}"
        fi
    done
    

    echo -e "---" >> $filename.yml
    echo -e "- name: $play_name" >> $filename.yml
    echo -e "  hosts: $play_hosts" >> $filename.yml
    echo -e "  become: $sudo_privileges" >> $filename.yml
}

create_play

echo "[=========== RESULT ===========]"
echo -e "Playbook [${LIGHT_GREEN}$filename.yml${NC}]: "
cat $filename.yml

