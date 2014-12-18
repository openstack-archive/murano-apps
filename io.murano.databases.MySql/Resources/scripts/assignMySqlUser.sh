#!/bin/bash

mysql --user=root --password=root -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost' WITH GRANT OPTION"
mysql --user=root --password=root -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'%' WITH GRANT OPTION"
mysql --user=root --password=root -e "FLUSH PRIVILEGES"
