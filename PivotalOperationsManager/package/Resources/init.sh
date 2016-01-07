#!/bin/sh

while true; do
    sleep 30
    if ps ax | grep -v grep | grep ruby > /dev/null
    then
        break
    fi
done

mkdir /tmp/murano

curl "https://localhost/api/setup" -d \
'setup[user_name]=%USER%&setup[password]=%PASS%&setup[password_confirmation]=%PASS%&setup[eula_accepted]=true' \
-X POST --insecure >> /tmp/murano/ops-config.log

installConfigBase64='%INSTALL_CONFIG_BASE64%'

echo $installConfigBase64 | base64 -d > /tmp/murano/installation.yml

perl -i -pe 's/\r\n$/\\n/g' /tmp/murano/installation.yml

cat << EOF > /tmp/murano/get_ver.py
#!/usr/bin/python
import json
import requests

r = requests.get('https://localhost/api/products', auth=('%USER%', '%PASS%'), verify = False)
products = r.json()
omver = ''
for prod in products:
    if prod["name"] == "p-bosh":
        omver = prod["product_version"]
        break
print omver
EOF

chmod 755 /tmp/murano/get_ver.py

VER=$(/tmp/murano/get_ver.py)

sed -i "s/%VER%/${VER}/g" /tmp/murano/installation.yml

curl "https://localhost/api/installation_settings" -F \
'installation[file]=@/tmp/murano/installation.yml' -X POST \
-u %USER%:%PASS% --insecure >> /tmp/murano/ops-config.log

# Notify Heat that configuration process is done
wc_notify --data-binary '{"status": "SUCCESS"}'
