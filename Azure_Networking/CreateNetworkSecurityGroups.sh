!#/bin/bash
# Logical segmentation - Network access controls
nsgs=("NSG-PROD-WESTEUR-INTERNAL" "NSG-PROD-WESTEUR-DMZ" "NSG-PROD-WESTEUR-DB")
declare -A nsg_rule_db=(
 ['rule_name']="access_internal_database_from_reserved"
 ['nsg']="NSG-PROD-WESTEUR-DB"
 ['protocol']="tcp"
 ['dest_port']=3306
 ['source_addr']="192.168.1.200-192.168.250"
)
declare -A nsg_rule_web=(
 ['rule_name']="ALLOW_WEB_TRAFFIC_TO_LB"
 ['nsg']="NSG-PROD-WESTEUR-DMZ"
 ['protocol']="tcp"
 ['dest_port']="80 443"
 ['source_addr']="192.168.2.6"
 ['dest_addr']="192.168.1.4 1921.168.1.6"
)
# Create Network Security Groups
# Create NSG Group
for nsg in "${nsgs[@]}";
do
 az network nsg create \
 -g "${general['group']}" \
 -n "$nsg"
 printf "%s" "$nsg"
done
# Add rule(s)
# Check if rule exists in Network Security Group
if [[ ! $(az network nsg rule show -g "${vm_settings['group']}" --nsg-name
"${nsg_rule_db['nsg']}" -n "${nsg_rule_db['rule_name']}" &> /dev/null) ]]; then
 printf "The Following rule does not exist %s in %s. Creating new rule %s\n"
"${nsg_rule_db['rule_name']}" "${nsg_rule_db['nsg']}" "${nsg_rule_db['rule_name']}";
 # CREATE RULE TO ALLOW SSH TRAFFIC FROM HOWEST
 az network nsg rule create \
 -g "${vm_settings['group']}" \
 --nsg-name "${nsg_rule_db['nsg']}" \
 -n "${nsg_rule_db['rule_name']}" \
 --protocol "${nsg_rule_db['protocol']}" \
 --destination-port-range "${nsg_rule_db['dest_port']}" \
 --source-address-prefixes "${nsg_rule_db['source_addr']}" \
 --priority 200
fi
# Check if rule exists in Network Security Group
if [[ ! $(az network nsg rule show -g "${vm_settings['group']}" --nsg-name
"${nsg_rule_web['nsg']}" -n "${nsg_rule_web['rule_name']}" &> /dev/null) ]]; then
 printf "The Following rule does not exist %s in %s. Creating new rule %s\n"
"${nsg_rule_web['rule_name']}" "${nsg_rule_web['nsg']}" "${nsg_rule_web['rule_name']}";
 # CREATE RULE TO ALLOW SSH TRAFFIC FROM HOWEST
 az network nsg rule create \
 -g "${vm_settings['group']}" \
 --nsg-name "${nsg_rule_web['nsg']}" \
 -n "${nsg_rule_web['rule_name']}" \
 --protocol "${nsg_rule_web['protocol']}" \
 --destination-port-range "${nsg_rule_web['dest_port']}" \
 --source-address-prefixes "${nsg_rule_web['source_addr']}" \
 --destination-address-prefixes "${nsg_rule_web['dest_addr']}" \
 --priority 200
fi 
