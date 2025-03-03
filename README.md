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

