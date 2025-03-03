#!/bin/bash

# ANSI colour codes
LIGHT_BLUE='\033[94m'
NC='\033[0m'

echo -e "Enter name for ${LIGHT_BLUE}NEW$rm{NC} playbook: "
read playbook_name

# Create playbook based on 'playbook_name' variable
touch "$playbook_name".yml