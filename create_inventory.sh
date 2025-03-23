#!/bin/bash


# Create inventory file
GRAYBG='\e[47m'
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
LIGHT_BLUE='\033[94m'
BLACK='\e[30m'
NC='\033[0m'

group_name=""
filename="inventory"


add_group() {
    echo -en "Enter ${LIGHT_GREEN}[Group name]${NC}: "
    read group_name
    echo -e "[$group_name]" >> $filename
}

add_hostname(){
    echo -en "\nAdd ${LIGHT_BLUE}host${NC}: "
    read host_name
    echo -e "$host_name" >> $filename
    while true; do
        
        echo -en "\nadd another ${LIGHT_BLUE}host${NC} to ${LIGHT_GREEN}[$group_name]${NC}? (yes/no): \n" 
        read add_host

        if [[ "$add_host" == "yes" ]]; then
            echo -en "\nAdd ${LIGHT_BLUE}host${NC}: "
            read host_name
            echo -e "$host_name" >> $filename
            continue
        elif [[ "$add_host" == "no" ]]; then
            echo "" >> $filename #empty space
            break
        else
            echo -e "${LIGHT_RED}Invalid input! yes or no${NC}"
        fi
    done
    
}

# create inventory 
create_inventory() {
    add_group

    add_hostname

    while true; do
        
        echo -en "\nwould you like to add another group? (yes/no): \n" 
        read finished

        if [[ "$finished" == "yes" ]]; then
            add_group
            add_hostname
            continue
        elif [[ "$finished" == "no" ]]; then
            break
        else
            echo -e "${LIGHT_RED}Invalid input! yes or no${NC}"
        fi
    done
}


# check if inventory file exists, if not, start 'create_inventory' function

if [[ -f "inventory" || -f "inventory.ini" ]]; then
    echo -e "File/: inventory - ${LIGHT_GREEN}EXISTS${NC}\n"
    cat $filename
else
    echo -e "File/: inventory - ${LIGHT_RED}DOESN'T EXIST${NC}\n"
    # create the inventory
    
    touch $filename
    create_inventory

    echo -e "\n${GRAYBG}${BLACK}Contents of inventory file:${NC} \n" 
    cat "$filename"
fi