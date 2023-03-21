
# Create Private DNS zone
az network private-dns zone create \
 --resource-group "${general['group']}" \
 --name "contoso.com"

 # Link zone to our virtual network
az network private-dns link vnet create \
 --resource-group "${general['group']}" \
 --zone-name "contoso.com" \
 --name "main.contoso.com" \
 -v "$vnet_name"
 -e false 

 az network private-dns record-set a add-record \
 -g "${general['group']}" \
 -z contoso.com \
 -n web-lb \
 -a 192.168.64.6
az network private-dns record-set a add-record \
 -g "${general['group']}" \
 -z contoso.com \
 -n web1 \
 -a 192.168.1.4
az network private-dns record-set a add-record \
 -g "${general['group']}" \
 -z contoso.com \
 -n web2 \
 -a 192.168.1.6
 
az network private-dns record-set cname set-record \
-g "${general['group']}" \
-z contoso.com \
-n www \
-c web-lb.contoso.com