!#/bin/bash
# ~ General
declare -A general=(
 ['group']="rg-DEF-TEST"
 ['location']="westeur"
)
declare -A route=(
 ['name']="def-gateway"
 ['next_hop_type']="VirtualAppliance"
 ['address_prefix']="0.0.0.0/0"
 ['next_hop_ip']="192.168.2.62"
)
declare -A routing_table=(
 ['name']="DEF_ROUTE_FW"
) 

# Create a routing table for the firewall
az network route-table create \
--name "${routing_table['name']}" \
--resource-group "${general['group']}"

# Create new default route to the firewall
az network route-table route create \
-g "${general['group']}" \
--route-table-name "${routing_table['name']}" \
-n "${route['name']}" \
--next-hop-type "${route['next_hop_type']}" \
--address-prefix "${route['address_prefix']}" \
--next-hop-ip-address "${route['next_hop_ip']}"