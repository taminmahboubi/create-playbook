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
LIGHT_YELLOW='\e[93m'
LGB='\e[102m'
LRB='\e[101m'
FAINT='\e[2m'
STRIKETHROUGH='\e[9m'
NC='\033[0m'


module_list=$(ansible-doc apt | awk '/OPTIONS \(= is mandatory\):/{flag=1; next} /ATTRIBUTES:/{flag=0} flag' | awk '/^-/{print $2}')

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





# create_play
echo "Select one:"
play_array=()

select_task() {
    local arr_name="$1"
    local -n options="$arr_name"

    done_selecting=$(colorization "[Done]" "92")
    options+=("$done_selecting")
    selected_options=()

    extra=""
    
    while true; do

        # Show fzf with multi-selection enabled
        #selection=$(printf "%s\n" "${options[@]}" | fzf --height 10 --border --reverse --multi --no-info --ansi)
        selection=$(printf "%s\n" "${options[@]}" | fzf --preview='
modules=("apt" "service" "copy" "file")
options""

for module in "${modules[@]}"; do
  option_modules=$(ansible-doc apt | awk "/OPTIONS \(= is mandatory\):/{flag=1; next} /ATTRIBUTES:/{flag=0} flag" | awk "/^-/{print $2}")

  options+="$module: $option_modules\n"
done

get_module() {
    module_param="$1"

    options_description=""

    for module in "${modules[@]}"; do
    module_params=$(ansible-doc "$module" | sed "/^- $module_param/,/type:/!d; /^- $module_param/d; /type:/q")
    options_description+="$module: $module_params\n"
    done

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

for item in ${options[@]}; do
    if [ {} == "$item" ]; then
        get_module "$item"
    fi
done

' --preview-window=down:10 --height 20 --border --reverse --multi --no-info --ansi)

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
                    continue
                fi

            done


        elif [[ "${#selected_options[@]}" -eq 0 && "$selection" == "[Done]" ]]; then
            echo -e "${LIGHT_RED}Error: you must choose at least one!${NC}"
            continue
        elif [[ "$selection" == *"[Done]"* ]]; then # If "Exit" is selected, break the loop
            echo "Selected:"

            for i in "${selected_options[@]}"; do
                echo -e "${LIGHT_GREEN}$i${NC}"
                play_array+=("$i")
            done
             
            break
        fi
    done
   
}

my_array=("name" "apt" "service")
select_task module_list



# list_tasks() {
#     echo -e "\n${GRAYBG}${BLACK}Select a Module:${NC}"

#     for item in "${tasks[@]}"; do
#         echo -e "${LIGHT_BLUE}[$item]${NC}"
#     done

#     while true; do
#         read -p "> " task_name

#         for item in "${tasks[@]}"; do
#             if [[ "$task_name" == "$item" ]]; then
#                 selected_task="$task_name"
#                 module_list=$(ansible-doc "$task_name" | awk '/OPTIONS \(= is mandatory\):/{flag=1; next} /ATTRIBUTES:/{flag=0} flag' | awk '/^-/{print $2}')
#                 play_array=()
#                 select_task module_list
#                 return  # Exit the function immediately
#             fi
#         done

#         echo -e "${LIGHT_RED}Error: Task '$task_name' not found. Try again.${NC}"
#     done
# }


#fzf --preview 'echo "Currently on: {}"' --preview-window=down:5




# items=(
#   "Apple"
#   "Banana"
#   "Cherry"
# )


# # Convert keys to a list for fzf selection
# selected_key=$(printf "%s\n" "${items[@]}" | fzf --preview='
# declare -A items
# items=(
#   ["Apple"]="A sweet red fruit."
#   ["Banana"]="A yellow fruit rich in potassium."
#   ["Cherry"]="A small red fruit, often in desserts."
# )

# for i in ${!items[@]}; do
#     if [ {} == "$i" ]; then
#         echo "${items[$i]}"
#     fi
# done

  
 
# ' --preview-window=down:5)






