!#/bin/bash
ids=$(az staticwebapp list \
 --resource-group "${general['group']}" \
 --query '[].[id]' \
 --output tsv)
# ~ Create Web Servers
az staticwebapp create \
-n "SWA-PROD-WESTEUR-PUBLIC01" \
-g "${general['group']}" \
-s "https://github.com/jonascap98/WEBSITE_DEPLOY_VNET" \
-b master \
--sku Standard \
--login-with-github
az staticwebapp create \
-n "SWA-PROD-WESTEUR-PUBLIC02" \
-g "${general['group']}" \
-s "https://github.com/jonascap98/WEBSITE_DEPLOY_VNET" \
-b master \
--sku Standard \
--login-with-github

# Private Endpoints
ids=$(az staticwebapp list \
 --resource-group "${general['group']}" \
 --query '[].[id]' \
 --output tsv)
i=0
for id in $ids;
do
 endpoint_name=$(echo "$id" | cut -d / -f9)
 # Create private endpoints
 az network private-endpoint create \
 --connection-name "${endpoint_name}" \
 --name "$endpoint_name" \
 --private-connection-resource-id "$id" \
 --resource-group "${general['group']}" \
 --subnet DMZ \
 --group-id staticsites \
 --vnet-name "$vnet_name"
 i=i+1
done 
