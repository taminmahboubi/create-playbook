#!/bin/bash

# ANSI colour codes
GRAY='\e[90m'
LIGHT_BLUE='\033[94m'
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
LIGHT_GRAY='\e[37m'
LIGHT_YELLOW='\e[93m'
BOLD='\e[1m'
FAINT='\e[2m'
LGB='\e[102m'
NC='\033[0m'

inventory_file="inventory"
inventory_list=$(grep "\[.*\]" $inventory_file | tr -d '[]') 
reversed_inventory=()
inventory_array=()
selected_groups=()

tasks=("apt" "service" "copy" "file")

echo -e "${LIGHT_GRAY}Enter File Name:${NC} "
read -p "> " filename

# Create playbook based on 'filename' variable
#touch "$filename".yml


declare -A group_index
index=1

check_inventory() {
    if [ -f "$inventory_file" ]; then
        echo -e "[inventory] - ${LIGHT_GREEN}AVAILABLE ●${NC}\n"

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
        echo -e "${LIGHT_RED}NO INVENTORY FILE ○${NC}"
    fi
    declare -g inventory_length=${#group_index[@]}
}

print_inventory() {
    echo -e "List of hosts in [inventory] file:"

    for key in $(printf "%s\n" "${!group_index[@]}" | sort -n); do
        echo -e "$key: ${LIGHT_GREEN}${group_index[$key]}${NC}"
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
            echo -e "\nSelect a number:[host] ${FAINT}(type '${BOLD}done${NC}${FAINT}' when finished, or '${BOLD}all${NC}${FAINT}' for all hosts)${NC}: "
            read -p "> " group_num

            if [[ "$group_num" =~ ^[0-9]+$ && -v group_index[$group_num] ]]; then
                echo -e "You have selected [${LIGHT_GREEN}${group_index[$group_num]}${NC}]"
                send_groups "${group_index[$group_num]}"
                remove_group "$group_num"
                print_inventory
                break
            elif [[ "$group_num" == "done" ]]; then
                if [ ${#selected_groups[@]} -eq 0 ]; then
                    echo -e "${LIGHT_RED}Invalid input, add minumum one host or '${BOLD}all${NC}${LIGHT_RED}'!${NC}"
                else
                    echo -e "${LIGHT_GREEN}Added!${NC}"
                    send_groups "${group_index[$group_num]}"
                    break
                fi
            elif [[ "$group_num" == "all" ]]; then
                for key in "${!group_index[@]}"; do
                    send_groups "${group_index[$key]}"
                done
                break
            else
                echo -e "${LIGHT_RED}Invalid input, try again!${NC}"
            fi
        done
    fi


}

send_groups() {
    group=$1

    selected_groups+=("$1")
}

list_tasks() {
    for item in "${tasks[@]}"; do
        echo -e "${LIGHT_BLUE}[$item]${NC}"
    done
}





create_play() {
    echo -e "\n${LIGHT_GRAY}Enter Play ${LIGHT_GREEN}[name]${NC}: "
    read -p "> " play_name

    
    echo -e "\n${LIGHT_GRAY}Enter groups (from inventory)${LIGHT_GREEN}[hosts]${NC}: "
    check_inventory
    hosts_num="${#selected_groups[@]}"
    play_hosts="${selected_groups[@]:0:$hosts_num}"


    echo -e "\n${LIGHT_GRAY}Grant sudo privilages? (yes/no)${NC} ${LIGHT_GREEN}[become]${NC} : "
    while true; do
        read -p "> " sudo_privileges

        if [[ "$sudo_privileges" == "yes" || "$sudo_privileges" == "no" ]]; then
            break
        else
            echo -e "${LIGHT_RED}Answer must be yes or no!${NC}"
        fi
    done

    echo -e "\n${LIGHT_GRAY}Select ${LIGHT_GREEN}[task]${NC}:"
    list_tasks

    # echo -e "---" >> $filename.yml
    # echo -e "- name: $play_name" >> $filename.yml
    # echo -e "  hosts: $play_hosts" >> $filename.yml
    # echo -e "  become: $sudo_privileges" >> $filename.yml
}

create_play

echo "[=========== RESULT ===========]"
echo -e "Playbook [${LIGHT_GREEN}$filename.yml${NC}]: "
#cat $filename.yml
echo -e "---"
echo -e "- name: $play_name"
echo -e "  hosts: $play_hosts"
echo -e "  become: $sudo_privileges"

