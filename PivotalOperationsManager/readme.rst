Pivotal Ops Manager for Murano
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This application allows to deploy Pivotal Operations Manager and configure
Manager Director

To deploy this application you need to download Ops Manager image from
network.pivotal.io and upload it to OpenStack with name "Ops Manager" and then
mark it as a Murano image. After that create environment, add application to
it, complete steps of configuring and start deployment.

.. note::
   You need to manually remove all VMs spawned by Ops Manager before
   deleting its environment.

Application supports 1.6.x.x releases of Ops Manager and was tested with
version 1.6.2.0

**Requirements for your OpenStack tenant**

* 70 GB of RAM
* 22 available instances
* 16 small VMs (1 vCPU, 1024 MB of RAM, 10 GB of root disk)
* 3 large VMs (4 vCPU, 16384 MB of RAM, 10 GB root disk)
* 32 vCPUs
* 1 TB of storage
* Neutron networking with floating IP support
