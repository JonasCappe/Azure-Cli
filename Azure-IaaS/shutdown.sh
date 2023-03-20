#!/bin/bash

# ~ Arguments
[[ $# -eq 1 ]] && group=$1

# ~ USER INPUT
# If empty povide by user input
[[ $# -eq 0 ]] && read -rp "Deallocate VMs in resource-group: " "group"

# Check if resource-group exists
if [[ ! $(az group show --name "$group") ]]; then
    printf "resource-group: %s does not exist\n" "$group"
    exit 22;
fi

vms_ids=$(az vm list -g "$group" --show-details --query "[?powerState!='VM deallocated'].{ id: id}" -o tsv)

if [[ ! "$vms_ids" == "" ]]; then
    if [[ ! $(az vm deallocate --ids $vms_ids) ]]; then
        exit 0;
    else
        exit 1;
    fi
fi