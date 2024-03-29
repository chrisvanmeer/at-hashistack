#!/bin/bash

# Define the inventory file
inventory_file="inventory"

# Check if the inventory file exists
if [ ! -f "$inventory_file" ]; then
    echo "Inventory file '$inventory_file' does not exist."
    exit 1
fi

# Define the awk command to extract servers under [all]
awk_command='/^\[all\]/ {flag=1; next} /^\[/ {flag=0} flag && NF {print $1}'

# Function to update inventory file
update_inventory() {
    # Import global variables
    local server_list="$1"

    # Query multipass list and store the output in a variable
    echo "Querying MultiPass..."
    multipass_list=$(multipass list | awk 'NR>1 { print $1, $3 }')

    # Create a mapping table for name to IPv4 address
    local -A ip_map
    while read -r name ip; do
        ip_map[$name]=$ip
    done <<< "$multipass_list"
    
    # Iterate over the server list
    for server in $server_list; do
        # Get the IP address from the mapping table
        local ip=${ip_map[$server]}

        # Replace the server name with '<servername> ansible_host=<ip>'
        sed -i "/^\[all\]$/,/^\[/ {
            /^\[all\]$/b
            /^\[/b
            /^[^[]/ s/${server//\//\\/}/${server//\//\\/} ansible_host=${ip//\//\\/}/
        }" "$inventory_file"
    done
}

# Function to launch multipass instances with cloud-init
launch_multipass() {
    # Import global variables
    local server_list="$1"

    # Determine the type of the default SSH key
    default_ssh_key_type=""
    if [ -f ~/.ssh/id_rsa ]; then
        default_ssh_key_type="rsa"
    elif [ -f ~/.ssh/id_ed25519 ]; then
        default_ssh_key_type="ed25519"
    fi

    # Generate a cloud-init file with user's SSH public key
    local cloud_init_file="at-hashistack-cloud-init.yaml"
    cat <<EOF > "$cloud_init_file"
#cloud-config
users:
  - default
  - name: $(whoami)
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat ~/.ssh/id_${default_ssh_key_type}.pub)
EOF

    # Iterate over the server list and launch multipass instances with cloud-init
    for server in $server_list; do
        # Launch multipass instance with cloud-init
        multipass launch --name "$server" --cloud-init "$cloud_init_file" --disk 10G
    done

    # Remove the cloud-init file after launching all instances
    rm "$cloud_init_file"
}


# Main script
if [ "$1" == "--inventory" ]; then
    # Execute the awk command to get the server list
    server_list=$(awk "$awk_command" "$inventory_file")
    
    update_inventory "$server_list"
    echo "Inventory file updated successfully."
elif [ "$1" == "--multipass" ]; then
    # Execute the awk command to get the server list
    server_list=$(awk "$awk_command" "$inventory_file")
    
    launch_multipass "$server_list"
    echo "Multipass instances launched successfully."
else
    echo "Usage: $0 [--inventory | --multipass]"
    exit 1
fi

