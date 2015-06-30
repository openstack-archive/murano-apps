Guacamole
---------

Guacamole is an HTML5 web application that provides access to desktop environments using remote desktop protocols
(such as VNC or RDP).

Logging In To Guacamole
-----------------------

The web login screen for Guacamole is available at http://server.host:server.port/guacamole. To login to Guacamole use
the username and password which you have specified before installing.

Logging In To Your Host
-----------------------

By default there will be three connections available: localhost-ssh, otherhost-vnc, otherhost-rdp. Connections
otherhost-vnc, otherhost-rdp are used as examples and can be useful later. So to get started use **localhost-ssh**
and the same username and password that you have used to login to Guacamole. After that you will already be at
/etc/guacamole. Here you can modify configuration if you need to use a different authentication module or if you
need to veer from the defaults.

Configuring Guacamole Default Authentication
--------------------------------------------

The default authentication provider used by Guacamole reads all username, password, and configuration information
from a file called the "user mapping". By default, Guacamole will look for this file at **/etc/guacamole/user-mapping.xml**.

Default user mapping file looks something like this:

.. code-block:: xml

    <user-mapping>
        <authorize username="..." password="..." encoding="md5">
            <connection name="localhost-ssh">
                <protocol>ssh</protocol>
                <param name="hostname">127.0.0.1</param>
                <param name="port">22</param>
            </connection>
            <connection name="otherhost-vnc">
                <protocol>vnc</protocol>
                <param name="hostname">otherhost</param>
                <param name="port">5901</param>
            </connection>
            <connection name="otherhost-rdp">
                <protocol>rdp</protocol>
                <param name="hostname">otherhost</param>
                <param name="port">3389</param>
            </connection>
        </authorize>
    </user-mapping>

Each user is specified with a corresponding <authorize> tag. This tag contains all authorized connections for that user,
each denoted with a <connection> tag. Each <connection> tag contains a corresponding protocol and set of protocol-specific
parameters, specified with the <protocol> and <param> tags respectively.

Applying configuration changes
------------------------------

There is no need to restart Tomcat or Guacamole services, all configuration changes will be applied after relogin.

For more info please visit - http://guac-dev.org/.
