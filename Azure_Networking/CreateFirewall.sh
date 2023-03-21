!#/bin/bash
declare -A general=(
 ['group']="JonasCap"
 ['location']="westeur"
)
vnet_name="VNet-PROD-WESTEUR-MAIN"
az network firewall create \
-name "fW-main" \
-g "${general['group']}" \
--vnet-name "$vnet_name"
az network public-ip create \
 --name fw-pip \
 --resource-group "${general['group']}" \
 --allocation-method static \
 --sku standard
az network public-ip show \
 --name fw-pip \
 --resource-group "fw-main"
fwprivaddr="$(az network firewall ip-config list -g ${general['group']} -f \"fw-main\" --query
"[?name=='FW-config'].privateIpAddress" --output tsv)" 