#!/bin/bash
#
# Copyright 2015 Oracle and/or its affiliates. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
. ./ora_env.sh

sql_file="$ORACLE_USER_HOME/pdb_create_user_$$.sql"

# get the address to attach to
lsnr=$($ORACLE_USER_HOME/get_listener.sh)
err=$?
if [[ $err -ne 0 ]]
then
  echo $lsnr;
  exit $err
fi

# create user
# grant all privileges
# TODO: privileges to be set based on what the ADMIN user is requesting
# from the client.

cat > $sql_file << EOF
CONNECT $SYSTEM_USER/$SYSTEM_USER_PWD@//$lsnr/$1;
SET LINESIZE 100;
SET PAGESIZE 50;
CREATE USER $2 IDENTIFIED BY "$3";
GRANT ALL PRIVILEGES to $2;
EXIT
EOF

chown oracle:oracle $sql_file
# Run this perl script so that the user information is
# updated properly on all the system meta files.
perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l $ORACLE_USER_HOME -b pupbld -u $SYSTEM_USER/$SYSTEM_USER_PWD $ORACLE_HOME/sqlplus/admin/pupbld.sql;

# Execute the sql
su - oracle -c " . ~/ora_env.sh && sqlplus /nolog @$sql_file"

# construct the connection string.
# echo the CONN string
# conn string is <username>/<pass>@//<ip_addr>:<port>/<pdb>

# echo "$2/$3@//$lnsr/$1"
echo "Connection host and port $lsnr"
rm -f $sql_file
