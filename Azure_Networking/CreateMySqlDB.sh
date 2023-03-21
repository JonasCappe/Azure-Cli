!#/bin/bash
declare -A db_settings=(
 ['user']="user01"
 ['name']="mysql-db01"
)
read -rsp "password: " db_settings['password']
az mysql server create \
--resource-group "${general['group']}" \
--name "${db_settings['name']}" \
--admin-user "${db_settings['user']}" \
--admin-password "${db_settings['password']}" \
--auto-grow Disabled \
--public-network-access Disabled \
--sku-name B_Gen5_1 \
--version 8.0 

az mysql server firewall-rule create \
--resource-group "${general['group']}" \
--server mysql-db01 \
--name ALLOW_ACCESS_INTERNAL \
--start-ip-address 192.168.0.200 \
--end-ip-address 192.168.0.250