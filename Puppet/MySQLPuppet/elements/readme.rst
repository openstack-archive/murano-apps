Puppet Elements
===============

This folder contains necessary DIB elements to build Puppet image
expected by "Puppet Example" Murano application.


Prerequisites
-------------

1. Install diskimage-builder

.. sourcecode:: bash

    sudo pip install diskimage-builder

2. Install qemu-utils and kpartx


On Ubuntu, Debian:

.. sourcecode:: bash

    sudo apt-get install qemu-utils kpartx

On Centos, Fedora:

.. sourcecode:: bash

    sudo yum install qemu-utils kpartx


Image building
--------------

.. sourcecode:: bash

    sudo ELEMENTS_PATH=${murano_agent_root}/contrib/elements:${murano_apps_root}/Example/PuppetExample/elements disk-image-create \
        vm ubuntu murano-agent puppet -o ubuntu14.04-x64-puppet

Where ${murano_agent_root} is a path to murano-agent files
and ${murano_apps_root} is a path to murano-apps files.
