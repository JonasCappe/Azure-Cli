!#/bin/bash
declare -A AGSubnet=(
 ['vnet']="$vnet_name"
 ['name']="AGSubnet"
 ['address_prefix']="192.168.64.0/29"
 ['crt']="${routing_table['name']}"
)
az network vnet subnet create \
-g "${general['group']}" \
--vnet-name "${AGSubnet['vnet']}" \
-n "${AGSubnet['name']}" \
--address-prefixes "${AGSubnet['address_prefix']}" \
--route-table "${AGSubnet['crt']}"
# Create the Public IP address voor de resources
az network public-ip create \
 --resource-group "${general['group']}" \
 --name AGPublicIPAddress \
 --allocation-method Static \
 --sku Standard
# Create de Application gateway
az network application-gateway create \
 --name AppGateway \
 --resource-group "${general['group']}" \
 --capacity 2 \
 --sku Standard_v2 \
 --public-ip-address AGPublicIPAddress \
 --vnet-name vnet_name \
 --subnet "${AGSubnet['name']}" \ 

 --servers "web1.jonascap.be" "web2.jonascap.be" \
 --priority 100
az network public-ip show \
 --resource-group "${general['group']}" \
 --name AGPublicIPAddress \
 --query [ipAddress] \
 --output tsv