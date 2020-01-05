
username=$(echo $1 | awk -F = {'print $2'})
password=$(echo $2 | awk -F = {'print $2'})

while IFS= read -r line
do
    shadow_user=$(echo "$line" | awk -F : {'print $1'})
    echo "$shadow_user $username"
    if [ "$shadow_user" != "$username" ]; then
        echo "diff"
    else
        echo "same"
    fi

    shadow_pass=$(echo "$line" | awk -F : {'print $2'})
    sha_number=$(echo "$shadow_pass" | awk -F $ {'print $2'})
    echo "$sha_number"

    
done < /etc/shadow