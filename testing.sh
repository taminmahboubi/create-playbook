# create an associtive array
declare -A my_array

# add elements in associative array
my_array["1"]="first"
my_array["2"]="second"
my_array["3"]="third"

for key in "${!my_array[@]}"; do
    echo "$key: ${my_array[$key]}"
done

#printf "%s\n" "${!group_index[@]}" | sort -n

printf "%s\n" "${!my_array[@]}" | sort -n

# print elements in single line
echo "${my_array[@]:0:3}"