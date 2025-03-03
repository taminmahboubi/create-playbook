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