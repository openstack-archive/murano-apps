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
. /etc/oraenv/ora_env.sh
. /etc/oraenv/orapwd
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/perl/bin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
# Find site_perl
site_perl=( $(/usr/bin/ls -r $ORACLE_HOME/perl/lib/site_perl) )

if [[ $(/usr/bin/uname -p) == 'sparc' ]]; then
    export PERL5LIB=$ORACLE_HOME/perl/lib/site_perl/${site_perl[0]}/sun4-solaris-64int:$ORACLE_HOME/perl/lib
else
    export PERL5LIB=$ORACLE_HOME/perl/lib/site_perl/${site_perl[0]}/i86pc-solaris-thread-multi-64:$ORACLE_HOME/perl/lib
fi
export PDBSEED=$ORADATA/pdbseed
