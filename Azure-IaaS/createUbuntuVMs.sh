#!/bin/bash
# STATIC SETTINGS
image="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:22.04.202209211"
size="Standard_B1ls"
location="westeurope"

declare -A nsg_rule=(
    ['rule_name']="remote_access"
    ['nsg']="access_linux_vm"
    ['protocol']="tcp"
    ['dest_port']=22
    ['source_addr']=""
)

# Number of VM's argument when given otherwise empty
[[ $# -eq 1 ]] && aantal=$1
[[ $# -gt 1 ]] && { printf "To many arguments provided! %s takes only 1 argument <number_of_vm_instances>\n" "$0"; exit 7; } # To may arg>

# ~ USER INPUT
# If empty povide by user input
[[ $# -eq 0 ]] && read -rp "Number of VM's: " aantal

# Check Input
[[ ! $aantal =~ [0-9]+ ]] && { printf "Invalid argument: %s only takes a number as argument, \"%s\" is not a number\n " "$0" "$aantal"; exit 22; }

declare -A vm_settings

read -rp "name: " vm_settings['name']
read -rp "resource-group: " vm_settings['group']
read -rp "tags (key:value - space sepperated): " vm_settings['tags']
read -rp "username: " vm_settings['username']

printf "SSH key options:\n"
select option in "provide existing public key" "create new key pair"
do
    case $REPLY in
        1)
            printf "Searching for keys...\n"
            keys=$(az sshkey list -g "${vm_settings['group']}" --query [].name | sed 's/[][]//g')

            if [[ ! $keys == "" ]]; then
                select key in $keys
                do
                    vm_settings['ssh']=" --ssh-key-name $key"
                    break
                done
            else
                printf "There are no existing keys in %s, adding option to generate keypair" "${vm_settings['group']}"
                vm_settings['ssh']=" --generate-ssh-keys"
            fi
            break
            ;;
        2)
            vm_settings['ssh']=" --generate-ssh-keys"
            break
            ;;
    esac
done

# Check if resource-group exists if not create
if [[ ! $(az group show --name "${vm_settings['group']}" &> /dev/null) ]]; then
    printf "resource-group: %s does not exist, creating new resource group %s\n" "${vm_settings['group']}" "${vm_settings['group']}"
    az group create -n "${vm_settings['group']}" -l "westeurope"
fi

# Check if Network Security Group exists in Resource Group
if [[ ! $(az network nsg show -g "${vm_settings['group']}" -n "${nsg_rule['nsg']}" &> /dev/null) ]]; then
    printf "NSG - %s not found! creating new Network Security Group %s\n" "${nsg_rule['nsg']}" "${nsg_rule['nsg']}";
    # Create NSG Group
    az network nsg create \
        -g "${vm_settings['group']}" \
        -n "${nsg_rule['nsg']}" \
        --tags "${vm_settings['tags']}"
fi

# Check if rule exists in Network Security Group
if [[ ! $(az network nsg rule show -g "${vm_settings['group']}"  --nsg-name "${nsg_rule['nsg']}" -n "${nsg_rule['rule_name']}" &> /dev/null) ]]; then
    printf "The Following rule does not exist %s in %s. Creating new rule %s\n" "${nsg_rule['rule_name']}" "${nsg_rule['nsg']}" "${nsg_rule['rule_name']}";
    # CREATE RULE TO ALLOW SSH TRAFFIC FROM HOWEST
    az network nsg rule create \
        -g "${vm_settings['group']}" \
        --nsg-name "${nsg_rule['nsg']}" \
        -n "${nsg_rule['rule_name']}" \
        --protocol "${nsg_rule['protocol']}" \
        --destination-port-range "${nsg_rule['dest_port']}" \
        --source-address-prefixes "${nsg_rule['source_addr']}" \
        --priority 101
fi

# Start time creating VM's
start_time=$(date +%M%S)

# Create VMs
for((vm=0; vm<aantal; vm++))
do
    cmd="az vm create -n \"${vm_settings['name']}_$(date +%y%m%d%H%M%S)\" -g \"${vm_settings['group']}\" --image \"$image\" --size \"$size\" --os-disk-delete-option delete --public-ip-sku Basic"
    [[ "${nsg_rule['nsg']}" ]] && cmd+=" --nsg \"${nsg_rule['nsg']}\""
    [[ "${vm_settings['username']}" ]] && cmd+=" --admin-username \"${vm_settings['username']}\""
    [[ "${vm_settings['ssh']}" ]] && cmd+="${vm_settings['ssh']}"
    [[ "${vm_settings['tags']}" ]] && cmd+=" --tags \"${vm_settings['tags']}\""

    printf "\n%s\n" "$cmd"

    [[ ! $(eval "$cmd") ]] && { printf "Something went wrong could not create VM %d, consult error.vmcreation file" "$vm"; exit 1; }

done && { echo "VMs created in $($(date +%M%S) - start_time) seconds."; exit 0; }