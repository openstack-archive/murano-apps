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
# Export env variables
. ./ora_env.sh

sql_file="$ORACLE_USER_HOME/pdb_create_$$.sql"

# Create pluggable database
# Open the pluggable database for read-write
cat > "${sql_file}" << EOF
CONNECT / as sysdba;
SET LINESIZE 100;
SET PAGESIZE 50;
CREATE PLUGGABLE DATABASE $1 ADMIN USER $ADMIN_USER IDENTIFIED BY $ADMIN_PWD roles=(CONNECT,DBA) FILE_NAME_CONVERT = ('$PDBSEED', '$ORADATA/$1');
ALTER PLUGGABLE DATABASE $1 OPEN;
EXIT;
EOF
chown oracle:oracle "${sql_file}"
# Execute the sql statements
su - oracle -c ". ~/ora_env.sh && sqlplus /nolog @$sql_file $1"
# remove the sql_file
rm -fv "${sql_file}"
