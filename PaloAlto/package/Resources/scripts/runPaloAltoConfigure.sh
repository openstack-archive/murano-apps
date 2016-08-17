#!/bin/bash
#  Licensed under the Apache License, Version 2.0 (the "License"); you may
#  not use this file except in compliance with the License. You may obtain
#  a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.

# $1 = role (backend/loadbalancer)
# $2 = backend ips

lb(){
  CONFIG=$(echo "$1" | tr ':' "\n" | while read -r line; do echo "  server ${line}:80;" ; done)
  sudo tee /etc/nginx/conf.d/backends.conf <<EOF
upstream backend {
${CONFIG}
}
EOF
  sudo tee /etc/nginx/sites-enabled/default <<EOF
server {
  listen 80 default_server;
  server_name localhost;

  location / {
    proxy_pass http://backend;
  }
}
EOF
  sudo /etc/init.d/nginx reload
  sudo sed -i 's|PasswordAuthentication no|PasswordAuthentication yes|' /etc/ssh/sshd_config
  sudo /etc/init.d/ssh restart
  echo 'ubuntu:ubuntu' | sudo chpasswd
}


http(){
  sudo tee /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to backend!</title>
</head>
<body>
<h1>Welcome to backend $(hostname)</h1>
</body>
</html>
EOF
}

case "$1" in
    "loadbalancer" )
        lb "$2"
    ;;
    "backend" )
        http
esac
