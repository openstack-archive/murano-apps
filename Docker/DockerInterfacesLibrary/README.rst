Docker Interface Library
========================

This library provides 3 major things:

* DockerApplication: base class that all Docker applications must inherit.
  Provides a way to define image name and docker container parameters.

* DockerContainerHost: interface for applications that provide Docker
  application hosting capabilities. Docker applications use this interface
  to deploy themselves on the Docker host.

* Data structures that are pass between DockerApplications and
  DockerContainerHosts. They define things like volumes, ports etc.
  Most important data structure is DockerContainer which describes the
  container itself.


DockerApplication
=================

This is the base class for all Docker applications. At minimum all inheritors
must provide an implementation of `getContainer` method. Everything else is
either optional or implemented in the base class.

It has the following properties:

* `host`: an instance of `DockerContainerHost`. This is the hosting provider
  (`DockerStandaloneHost`, `KubernetesPod`, etc.) that applications should
  be deployed to.

* `applicationEndpoints`: output property that is filled with application
  endpoints after deployment. See below for exact format details.

Class also has the following methods:

* `getContainer`: returns an instance of `DockerContainer` class that describes
  container information. Alternatively method can return a properties
  dictionary that would automatically be converted to `DockerContainer` by
  MuranoPL. This method must be implemented by inheritors!

* `deploy`: used to deploy Docker application on given `DockerContainerHost`.
  This method is already implemented in this class and should not be overridden
  by inheritors. It relies on the information returned by `getContainer`.

* `getConnectionTo`: used to get full endpoint for another Docker application's
  port when there is a need to connect two Docker applications.
  Requires three parameters:

    * `application`: an instance of `DockerApplication` that we want to
      talk to.
    * `port`: port number of the target application.
    * `protocol`: `TCP` or `UDP`.

  Returns a dictionary with two keys - `host` and `port` that represent the
  endpoint. Note that target application must be deployed before calling this
  method so it is advised to call `deploy()` first.

  See `DockerGrafana/DockerInfluxDB` as an example or connected Docker
  applications.

* `onInstallationStart`: a method that get get called when installation starts.
  May be overridden by inheritor class to provide extra logging or reporting.

* `onInstallationFinish`: a method that get get called when installation ends.
  May be overridden by inheritor class to provide extra logging or reporting.


DockerContainer
===============

This is a data structure defining a Docker container.

It has the following properties:

* `name`: container name. Must be unique within single `DockerContainerHost`.
  This is the same as application name for regular
  applications.

* `image`: Docker image name.

* `commands`: optional list of shell commands to execute upon container start.

* `env`: a dictionary of environment key-values (inputs for Docker containers)

* `ports`: a list of `ApplicationPort` instances. This is a list of ports that
  need to be opened/exposed by the container.

* `volumes`: an optional mapping that defines volumes that need to be mounted
  into Docker container. Keys are the paths within container and values are
  instances of DockerVolume.


ApplicationPort
===============

Defines a network port that need to be exposed by the application.
This is a structure with three properties:

* `port`: port number

* `protocol`: `TCP` or `UDP`

* `scope`: one of `public`, `cloud`, `host` or `internal`.
  This property specifies the scope of port visibility: within the single
  docker instance (on single server) - `host`, within single
  `DockerContainerHost` - `internal`, single OpenStack cloud - `cloud`
  or `public` for ports that are bind to public floating IP.



DockerVolume
============

Represents base class for Docker volumes. One of the two inheritors must be
used:

* `DockerTempVolume`: temporary storage space

* `DockerHostVolume`: a directory on the host machine that is mounted inside
  container. The path on host server is specified by the `path` property
  of `DockerHostVolume`.


DockerContainerHost
===================

Defines an interface that all applications capable of hosting Docker
applications must implement. Currently there are two implementations of this
interface: `DockerStandaloneHost` and `KubernetesPod`.

It has the following property:

* `name`: name of the application instance.

It also has the following methods:

* `hostContainer`: Docker applications call this method to register Docker
  containers on the Docker host during deployment. It accepts single argument -
  `container` - an instance of DockerContainer class.

  `deleteContainer`: deletes container from Docker host. Container is
  identified by its name through `name` parameter.

  `getEndpoints`: returns a list of endpoints for specified Docker container
  Container is identified by its name through `applicationName` parameter.
  See below on endpoint format specification.

  `getInternalScopeId`: returns an common identifier for all Docker hosts
  belonging to the same container manager (host aggregation used to group
  together endpoints of `internal` scope.


Endpoint representation
=======================

Docker container hosts are responsible for management of application
endpoints. Application define what ports they want to expose and what
should be the scope of visibility for those ports. It is up to the host
to map those ports to ports on hosting server and OpenStack floating IPs.

Single port on the container might be accesses in different ways.
It usually it may be accessed using 127.0.0.1 address from other containers
on the same server, using internal IP from containers on the same cluster,
using internal OpenStack server IP from other servers in the same environment
or using floating IP for external access. Scope defines maximum level of
visibility in the order `host` -> `internal` -> `cloud` -> `public`.
Each subsequent scope extends the visibility for the previous one. So if
the application wants a `public` endpoint for its port the host allocates four
endpoints for that port starting from 127.0.0.1:port to access it from the
same server and up to FIP:port to access it from the Internet. Thus
each port/protocol pair results in 1-4 entries in `applicationEndpoints` list.

Each entry of that list is a dictionary that has the following keys:

* `address`: IP or hostname.
* `port`: port number that caller must use to access the application.
* `scope`: greatest visibility scope name for the endpoint.
* `portScope`: scope name for the port endpoint was allocated for. For example
  if `ApplicationPort` had a 'local` scope then two endpoints will be allocated
  (`host` and `local` and each of them will have `local` in `portScope`).
* `containerPort`: port number inside the container.
* `protocol`: `TCP` or `UDP`. There can be two endpoints with the same port
  number that differ only in protocol.


Tips on Docker applications development
=======================================

* MuranoPL can automatically convert dictionaries to an instances of
  appropriate class when passing it as an input to a function that has
  proper class() contract on that value. Thus in most cases data structures
  can be represented as a dictionaries of property name->value form rather
  than as MuranoPL objects (thus no need to use new() function to construct
  them)

* Use `getConnectionTo` method of DockerApplication to get endpoint to
  access one docker application from another. If application A wants to talk
  to application B then this method is called on A with an information about
  what port of B it requires. The method is smart enough to return the nearest
  endpoint. This if both A and B are located on the same server returned
  endpoint will likely to have 127.0.0.1 as an address.

* Call deploy() on dependent applications before retrieving endpoints or
  obtaining connections to it.
