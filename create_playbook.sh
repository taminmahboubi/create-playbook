#!/bin/bash

# ANSI colour codes
GRAY='\e[90m'
BLACK='\e[30m'
LIGHT_BLUE='\033[94m'
LIGHT_GREEN='\033[92m'
LIGHT_RED='\033[91m'
LIGHT_GRAY='\e[37m'
LIGHT_YELLOW='\e[93m'
BOLD='\e[1m'
FAINT='\e[2m'
LGB='\e[102m'
LRB='\e[101m'
GB='\e[42m'
NC='\033[0m'

inventory_file="inventory"
inventory_list=$(grep "\[.*\]" $inventory_file | tr -d '[]') 
reversed_inventory=()
inventory_array=()
selected_groups=()

tasks=("apt" "service" "copy" "file")


# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "fzf - ${LRB}NOT installed.{$NC} Installing now..."

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

    echo -e "fzf - ${LIGHT_GREEN}installed successfully!${NC}"
else
    echo -e "fzf - ${LGB}Installed${NC}"
fi

colorization() {
    local num_args=$# # Get the number of arguments

    if [[ $num_args -eq 2 ]]; then
        local keyword="$1"
        local colourcode="$2"

        echo -e "\\e[${colourcode}m$keyword\\e[0m"

    elif [[ $num_args -eq 3 ]]; then
        local text="$1"
        local keyword="$2"
        local colourcode="$3"

        # Define the keywords and their colours (Associtive array)
        local -A change_colours=()

        # store the word and colour code you want to change it to
        change_colours["$keyword"]="$colourcode"
        
        text=$(echo -e "$text" | sed "s/\($keyword\)/\\\e[${colourcode}m\1\\\e[0m/g")

        echo -e "$text"
    else 
        echo -e "${LIGHT_RED}Function called with an unexpected number of arguments${NC}"
    fi

}



get_module() {
    module_param="$1"

     # command ansible-doc apt | sed '/^- update_cache/,$!d' | awk '/^  /{print} /type:/{exit}'
    options_description=$(ansible-doc apt | sed "/^- $module_param/,/type:/!d; /^- $module_param/d; /type:/q")

    # Define the keywords and their colors
    declare -A colors=(
    ["aliases:"]="93"  # Yellow
    ["default:"]="93"
    ["type:"]="93" 
    )

    # Apply colorization using sed
    for keyword in "${!colors[@]}"; do
        color_code="${colors[$keyword]}"
        options_description=$(echo "$options_description" | sed "s/\($keyword\)/\\\e[${color_code}m\1\\\e[0m/g")
    done
  

    echo -e "$options_description"

}



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
                    echo -e "[hosts]- ${LGB} Added!${NC}"
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
    echo -e "\nSelect a Module:"

    for item in "${tasks[@]}"; do
        echo -e "${LIGHT_BLUE}[$item]${NC}"
    done

    while true; do
        read -p "> " task_name

        for item in "${tasks[@]}"; do
            if [[ "$task_name" == "$item" ]]; then
                module_list=$(ansible-doc "$task_name" | awk '/OPTIONS \(= is mandatory\):/{flag=1; next} /ATTRIBUTES:/{flag=0} flag' | awk '/^-/{print $2}')
                play_array=()
                select_task module_list
                return  # Exit the function immediately
            fi
        done

        echo -e "${LIGHT_RED}Error: Task '$task_name' not found. Try again.${NC}"
    done
}





select_task() {
    local arr_name="$1"
    local -n options="$arr_name"

    done_selecting=$(colorization "[Done]" "92")
    options+=("$done_selecting")
    selected_options=()
    
    while true; do

        # Show fzf with multi-selection enabled
        selection=$(printf "%s\n" "${options[@]}" | fzf --height 10 --border --reverse --multi --no-info --ansi)

        if [[ -n "$selection" && "$selection" != "[Done]" ]]; then # if the string is -n (not empty) and the selection is not equal to [Done] 
           

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
                    get_module "$item"
                    continue
                fi

            done


        elif [[ "${#selected_options[@]}" -eq 0 && "$selection" == "[Done]" ]]; then
            echo -e "${LIGHT_RED}Error: you must choose at least one!${NC}"
            continue
        elif [[ "$selection" == *"[Done]"* ]]; then # If "Exit" is selected, break the loop

            for i in "${selected_options[@]}"; do
                play_array+=("$i")
            done
             
            break
        fi
    done
}





create_task() {
    echo -e "\n${LIGHT_GRAY}Enter name for ${LIGHT_GREEN}[task]${NC}:"
    read -p "> " task_title

    list_tasks    

    declare -gA task_key=()

    for task in "${play_array[@]}"; do
        read -p "$task: > " task_title
        task_key[$task]="$task_title"
    done 

    
}

send_tasks() {
    echo -e "    - name: $task_title"
    echo -e "      $task_name:"

    for key in "${!task_key[@]}"; do
         echo -e "        $key: ${task_key[$key]}"
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

    create_task
    



    # echo -e "---" >> $filename.yml
    # echo -e "- name: $play_name" >> $filename.yml
    # echo -e "  hosts: $play_hosts" >> $filename.yml
    # echo -e "  become: $sudo_privileges" >> $filename.yml
    # echo -e "  tasks:" >> $filename.yml
    #send_tasks
}

create_play

echo "[=========== RESULT ===========]"
echo -e "Playbook [${LIGHT_GREEN}$filename.yml${NC}]: "
#cat $filename.yml
echo -e "---"
echo -e "- name: $play_name"
echo -e "  hosts: $play_hosts"
echo -e "  become: $sudo_privileges"
echo -e "  tasks:" 
send_tasks

    #echo -e "${LRB}DEBUG:${NC}"
