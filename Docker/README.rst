Docker support for Murano
=========================

Docker is an open-source project that automates the deployment of applications
inside software containers. Docker containers could be run either by the
Docker itself or by container management platforms that built on top of the
Docker and provide extra value to schedule and manage containers on multiple
hosts.


This folder contains needed abstractions and applications to develop and
run Docker applications:

* DockerInterfaceLibrary: library that defines a framework for building Docker
  applications. It provides set of common interfaces and data structures
  that are used by all Docker applications and Docker hosting services.
  If you want to develop your own Docker application this is a good place to
  start. See DockerInterfaceLibrary/README.rst for more details.

* DockerStandaloneHost: a regular Docker host. Docker containers are run on
  a dedicated VM running docker software (require pre-built image with
  docker and murano-agent).

* Kubernetes: an open source container cluster manager by Google. It allows
  to schedule and run Docker applications on multiple clustered nodes.
  Application both installs Kubernetes and provides capabilities to run
  Docker applications similar to DockerStandaloneHost.

* Applications: Examples of some of the most popular Docker applications.
