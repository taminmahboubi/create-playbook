#!/bin/bash

# ANSI colour codes
LIGHT_BLUE='\033[94m'
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
NC='\033[0m'

echo -e "Enter filename for ${LIGHT_BLUE}NEW${NC} playbook: "
read filename

# Create playbook based on 'filename' variable
touch "$filename".yml

create_play() {
    echo -e "${LIGHT_GREEN}Define the playbook name:${NC} "
    read play_name

    echo -e "${LIGHT_GREEN}Specify the target group (from inventory)${NC}: "
    read play_hosts

    echo -e "${LIGHT_GREEN}Grant sudo privilages?${NC}: "
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

