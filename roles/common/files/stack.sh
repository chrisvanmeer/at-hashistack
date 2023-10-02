#!/bin/bash
#
# stack.sh - A shell script to retrieve status information for a stack of services.
#
# Author: Chris van Meer
# Date: 20231002
# Description: This script provides a convenient way to check the status of various
#              services in a stack, including Consul clients and servers, Consul servers,
#              Vault servers, Nomad clients and servers, and Nomad servers.
#
# Usage: ./stack.sh <status>
#
# Available commands:
#   status - Display status information for all services (Consul clients and servers,
#            Consul servers, Vault servers, Nomad clients and servers, Nomad servers)
#   help   - Display usage information

# Function to display usage
display_usage() {
    echo "Usage: $0 <status>"
    echo "Available commands:"
    echo "  status - Display details about the Stack"
    echo "  help - Display this help message"
}

# Check if the required argument is provided
if [ $# -lt 1 ]; then
    display_usage
    exit 1
fi

# Process the provided argument
case "$1" in
    "status")
        clear
        # Command to display all Consul clients and servers
        echo "Consul Members:"
        echo "==============="
        consul members

        # Command to display all Consul servers
        echo 
        echo "Consul Servers:"
        echo "==============="
        consul operator raft list-peers

        # Command to display all Vault servers
        echo 
        echo "Vault Servers:"
        echo "=============="
        vault operator raft list-peers

        # Command to display all Nomad clients and servers
        echo 
        echo "Nomad Nodes:"
        echo "============"
        nomad node status

        # Command to display all Nomad servers
        echo 
        echo "Nomad Servers:"
        echo "=============="
        nomad operator raft list-peers
        ;;
    "help")
        # Display usage
        display_usage
        ;;
    *)
        # Invalid argument
        echo "Error: Invalid argument '$1'."
        display_usage
        ;;
esac
