Kubernetes Elements
===================

This folders contains necessary DIB elements to build Kubernetes image
expected by "Kubernetes Cluster" Murano application.


Prerequisites
-------------

1. Install diskimage-builder

.. sourcecode:: bash

    sudo pip install diskimage-builder

2. Install qemu-uils and kpartx

On Ubuntu, Debian:

.. sourcecode:: bash

    sudo apt-get install qemu-utils kpartx


On Centos, Fedora:

.. sourcecode:: bash

    sudo yum install qemu-utils kpartx


Image building
--------------

To build Debian-based image

.. sourcecode:: bash

   sudo ELEMENTS_PATH=${murano_agent_root}/contrib/elements:${murano_apps_root}/Docker/Kubernetes/KubernetesCluster/elements \
       DIB_RELEASE=jessie DIB_CLOUD_INIT_DATASOURCES="Ec2, ConfigDrive, OpenStack" disk-image-create vm debian murano-agent-debian \
       docker kubernetes -o debian8-x64-kubernetes

To build Ubuntu-based image

.. sourcecode:: bash

    sudo ELEMENTS_PATH=${murano_agent_root}/contrib/elements:${murano_apps_root}/Docker/Kubernetes/KubernetesCluster/elements disk-image-create \
        vm ubuntu murano-agent docker kubernetes -o ubuntu14.04-x64-kubernetes

Where ${murano_agent_root} is a path to murano-agent files
and ${murano_apps_root} is a path to murano-apps files.