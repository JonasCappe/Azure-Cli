!#/bin/bash
# Address space
vnet_name="VNet-PROD-WESTEUR-MAIN"
address_space="192.168.0.0/16"
# Subnets
declare -A internal=(
 ['vnet']="$vnet_name"
 ['name']="INTERNAL"
 ['address_prefix']="192.168.0.0/24"
 ['nsg']="NSG-PROD-WESTEUR-INTERNAL"
 ['crt']="${routing_table['name']}"
)
declare -A dmz=(
 ['vnet']="$vnet_name"
 ['name']="DMZ"
 ['address_prefix']="192.168.1.0/24"
 ['nsg']="NSG-PROD-WESTEUR-DMZ"
 ['crt']="${routing_table['name']}"
)
declare -A firewall=(
 ['vnet']="$vnet_name"
 ['name']="AzureFirewallSubnet"
 ['address_prefix']="192.168.2.0/26"
)
declare -A ApplicationGateway=(
 ['vnet']="$vnet_name"
 ['name']="AppGatewaySubnet"
 ['address_prefix']="192.168.64.0/29"
 ['crt']="${routing_table['name']}"
) 

# Create virtual network
az network vnet create \
--name "$vnet_name" \
-g "${general['group']}" \
--address-prefix "$address_space" 

# Create new subnets attached to NSG and custom route table
az network vnet subnet create \
-g "${general['group']}" \
--vnet-name "${internal['vnet']}" \
-n "${internal['name']}" \
--address-prefixes "${internal['address_prefix']}" \
--network-security-group "${internal['nsg']}" \
--route-table "${internal['crt']}"
az network vnet subnet create \
-g "${general['group']}" \
--vnet-name "${dmz['vnet']}" \
-n "${dmz['name']}" \
--address-prefixes "${dmz['address_prefix']}" \
--network-security-group "${dmz['nsg']}" \
--route-table "${dmz['crt']}"

az network vnet subnet create \
-g "${general['group']}" \
--vnet-name "${firewall['vnet']}" \
-n "${firewall['name']}" \
--address-prefixes "${firewall['address_prefix']}"
az network vnet subnet create \
-g "${general['group']}" \
--vnet-name "${['vnet']}" \
-n "${ApplicationGateway['name']}" \
--address-prefixes "${ApplicationGateway['address_prefix']}" \
--network-security-group "${ApplicationGateway['nsg']}" \
--route-table "${ApplicationGateway['crt']}