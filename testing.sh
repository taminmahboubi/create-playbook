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


filename=$(dialog --inputbox "Enter a file name:" 10 40 2>&1 >/dev/tty)
clear

create_play() {
    play_name=$(dialog --inputbox "Enter Play-[name]:" 10 40 --nocancel 2>&1 >/dev/tty)

    play_hosts=$(dialog --inputbox "Enter groups (from inventory)-[hosts]:" 10 40 2>&1 >/dev/tty --nocancel)
    # check_inventory
    # hosts_num="${#selected_groups[@]}"
    # play_hosts="${selected_groups[@]:0:$hosts_num}"

    sudo_privileges=$(dialog --inputbox "Grant sudo privileges? (yes/no)-[become]:" 10 40 2>&1 >/dev/tty --nocancel)
    # while true; do
    #     read -p "> " sudo_privileges

    #     if [[ "$sudo_privileges" == "yes" || "$sudo_privileges" == "no" ]]; then
    #         break
    #     else
    #         echo -e "${LIGHT_RED}Answer must be yes or no!${NC}"
    #     fi
    # done    
    clear

    # echo -e "---" >> $filename.yml
    # echo -e "- name: $play_name" >> $filename.yml
    # echo -e "  hosts: $play_hosts" >> $filename.yml
    # echo -e "  become: $sudo_privileges" >> $filename.yml
}


create_play


