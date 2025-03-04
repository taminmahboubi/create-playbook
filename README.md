# create-playbook
Create a playbook using a script

1. First, create a script:
we'll call it `create_playbook.sh`

2. The script needs to create a playbook, do that using: 
```bash
touch my_playbook.yml
```

3. Change it so, we are prompted to enter the name of the new playbook, rather than hardcoding it ourselves.
```bash
#!/bin/bash

# ANSI colour codes
LIGHT_BLUE='\033[94m'
NC='\033[0m'

echo -e "Enter name for ${LIGHT_BLUE}NEW$rm{NC} playbook: "
read playbook_name

# Create playbook based on 'playbook_name' variable
touch "$playbook_name".yml
```
    - Added ANSI colour codes
    - used `read` to take input from the user and store in the 'playbook_name' variable
    - created a `.yml` file using the user inputted name 

4. basic structure of a .yml playbook:
```bash
---
- name: Example Playbook
  hosts: target_group
  become: yes  # Run tasks as sudo (optional)

  tasks:
    - name: Ensure a package is installed
      apt:  # Use `yum` for RHEL-based systems
        name: package_name
        state: present

    - name: Copy a configuration file
      copy:
        src: /local/path/to/file
        dest: /remote/path/to/file
        owner: root
        group: root
        mode: '0644'

    - name: Restart a service
      systemd:
        name: service_name
        state: restarted
        enabled: yes

```
    - we could use `echo "some code" > file_name.yml`, but that would overwrite the whole script everytime we added a new line, so we could use `echo "some code" >> file_name.yml` instead.
    - This however still will cause indenting and newline issues, so we could try out `echo -e` with `"\n"`

I will initially create a seperate function to create each **play** (`name`, `hosts`, `become`, and `tasks`) called `create_play()`.

```bash
#!/bin/bash

# ANSI colour codes
LIGHT_BLUE='\033[94m'
LIGHT_GREEN='\033[92m'
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

    echo -e "${LIGHT_GREEN}Grant sudo privilages?${NC} (yes/no): "
    read sudo_privileges

    echo -e "---" >> $filename.yml
    echo -e "- name: $play_name" >> $filename.yml
    echo -e "  hosts: $play_hosts" >> $filename.yml
    echo -e "  become: $sudo_privileges" >> $filename.yml
}

create_play

echo -e "Playbook [${LIGHT_GREEN}$filename.yml${NC}]: "
cat $filename.yml
```

5. Next, we want to make sure that the user has specified the correct sudo privileges (chosen either 'yes' or 'no'):
    - we'll use a while loop, to keep looping until **yes** or **no** is inputted, otherwise give a error type response.
```bash
    echo -e "${LIGHT_GREEN}Grant sudo privilages?${NC}: "
    while true; do
        read -p "Enter yes or no: " sudo_privileges

        if [[ "$sudo_privileges" == "yes" || "$sudo_privileges" == "no" ]]; then
            break
        else
            echo -e "${LIGHT_RED}Answer must be yes or no!${NC}"
        fi
    done
```

6. Next, I want the script to check if there is an `inventory`/`inventory.ini` file, if there is, to list the hosts from that file, allowing the user to select from them.
`inventory` files are typically written like:
```
[web_servers]
192.168.1.10
192.168.1.11

[db_servers]
192.168.1.20

[app_servers]
192.168.1.30 ansible_user=myuser
```

- I can use `grep "\[.*\]" inventory` find the group(s) within an inventory file.
- Create an empty array to store the groups within the inventory file: `inventory_array=()`
- then create a function to check if the inventory file exists, if it does, add the list of inventories in the command into the array using a "while read loop":

```bash
check_inventory() {
    if [ -f "$inventory_file" ]; then
        echo "inventory file EXISTS:"

        while IFS= read -r line; do
            inventory_array+=("$line")
        done <<<"$inventory_list"

        for i in "${inventory_array[@]}"; do
            echo "$i"
        done
    else
        echo "NO INVENTORY FILE"
    fi
}
```
**Output:**

```
inventory file EXISTS:
[web_servers]
[db_servers]
[app_servers]
```


I've also added an **Associative Array**, this is an array where you can use names (keys) to find values, not just numbers.
The Associative Array will help me to select a group from the inventory file, based on a key, allowing the user of the script to manually select which group(s) they want.

*UPDATED CODE:*
```bash
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
```
**Output:**
```
inventory file EXISTS:
(1) [web_servers]
(2) [db_servers]
(3) [app_servers]
Select a group: 2
you have selected [db_servers]
```

A check is also implemented to see if the user has entered a number higher than the number of groups in the *inventory* file, or if they pressed another key on the keyboard:
```bash
elif [[ "$group_num" -gt "${#group_index[@]}" || ! "$group_num" =~ ^[0-9]+$ ]]; then
```

