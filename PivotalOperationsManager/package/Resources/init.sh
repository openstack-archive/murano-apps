#!/bin/bash

# Wait until service starts
while true; do
    sleep 30
    if pgrep [r]uby > /dev/null
    then
        break
    fi
done

# Create folder for murano actions
mkdir /tmp/murano

# Register user in ops manager
echo -e 'Create the first user:\n' >> /tmp/murano/ops-config.log

curl "https://localhost/api/setup" -d \
'setup[user_name]=%USER%&setup[password]=%PASS%&setup[password_confirmation]=%PASS%&setup[eula_accepted]=true' \
-X POST --insecure >> /tmp/murano/ops-config.log

# Write user's settings to file
installConfigBase64='%INSTALL_CONFIG_BASE64%'
echo $installConfigBase64 | base64 -d > /tmp/murano/user-installation.yml

# Write python script to file
mergeSettingsScript='%MERGE_SETTINGS_BASE64%'
echo $mergeSettingsScript | base64 -d > /tmp/murano/merge_settings.py

# Replace 'line break' symbol with text 'line break'
# Without this action Ops manager gets incorrect ssh private key
perl -i -pe 's/\r\n$/\\n/g' /tmp/murano/user-installation.yml

# Get installation settings of 'bare' Ops Manager
curl "https://localhost/api/installation_settings" -X GET \
-u %USER%:%PASS% --insecure > /tmp/murano/bare-installation.yml

# Merge settings
echo -e "Merging installation settings\n" >> /tmp/murano/ops-config.log
python /tmp/murano/merge_settings.py >> /tmp/murano/ops-config.log

if [ ! -f /tmp/murano/installation.yml ]; then
    echo "File with settings is not found!" >> /tmp/murano/ops-config.log
    wc_notify --data-binary '{"status": "FAILURE"}'
fi

echo -e "Importing settings to Ops Manager:\n" >> /tmp/murano/ops-config.log
curl "https://localhost/api/installation_settings" -F \
'installation[file]=@/tmp/murano/installation.yml' -X POST \
-u %USER%:%PASS% --insecure >> /tmp/murano/ops-config.log

# Save log
mkdir /var/log/murano
mv /tmp/murano/ops-config.log /var/log/murano/

# Clear data
rm -rf /tmp/murano

# Notify Heat that configuration process is done
wc_notify --data-binary '{"status": "SUCCESS"}'
