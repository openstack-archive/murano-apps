====================
Oracle PDB Connector
====================

Description
-----------

Oracle PDB Connector is a Murano application that provides OpenStack cloud
users with means for self-service provisioning of Oracle Database 12c and
Oracle Multitenant Pluggable DataBases (PDBs).

This is an unsupported technology preview release not intended for use in
production environments.  It is supported on the Juno and Kilo OpenStack
releases.

Instructions
------------

1. You must first install and configure Oracle Database 12c with the Oracle
   Multitenant option on Oracle Solaris 11.2.

   Create a file ``/etc/oraenv/ora_env.sh`` with read/write permissions for
   the ``oracle`` user, and set the following environment variables (with
   values appropriate for your installation)::



     ORACLE_BASE=/path/to/oracle    # The base directory of Oracle database
                                    #  installation
     ORACLE_HOME=$ORACLE_BASE/<oracle12c directory> # oracle home
     ORACLE_SID=<sid>               # Oracle System Identifier
     ORADATA=/path/to/data          # Oracle application directory
                                    # e.g. /u01/app/oracle/oradata
     ORACLE_USER_HOME=/home/oracle  # Home directory of user oracle

   Now create a file ``/etc/oraenv/orapwd``, also with read/write permissions
   for the ``oracle`` user, and add the names and passwords for the admin and
   system users::

    ADMIN_USER=
    SYSTEM_USER=
    ADMIN_PWD=
    SYSTEM_USER_PWD=

2. You will also need the latest Murano agent.

  - Download the latest tarball of murano-agent and its dependent packages
    on the node where Oracle 12c is running.

  - Install each of the package by doing the following::

    # tar -zxvf <package>.tar.gz
    # cd <package>
    # ./setup.py build
    # ./setup.py install

  - The executable ``muranoagent`` will be made available in ``/usr/bin``.

  - Set up the agent by copying the sample configuration file to
    ``/etc/murano/agent.conf``.

  - Edit ``/etc/murano/agent.conf`` and set ``enable_dynamic_result_queue``
    to ``True`` in the ``DEFAULT`` section.  Set ``input_queue`` with queue
    information from the murano engine.

  - Start the agent::

    # /usr/bin/muranoagent --config-file /etc/murano.conf

3. Install the latest version of the plugin required by this application,
   available from PyPI::

   # pip install murano.plugins.static-agent

   After the plugin is installed, restart the murano engine.
