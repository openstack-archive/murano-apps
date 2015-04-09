# Google Kubernetes for Murano

Packages in this folder are required to deploy both Google Kubernetes and applications 
on top of it.

Contents of each folder need to be zipped and uploaded to Murano Application Catalog. 
You will also need to build proper Ubuntu image for Kubernetes. 
This can be done using diskimage-builder (https://github.com/openstack/diskimage-builder) and 
DIB elements (https://github.com/stackforge/murano/tree/master/contrib/elements/kubernetes).

Applications expect the following images:

* ubuntu14.04-x64-kubernetes.qcow2 for Kubernetes
* ubuntu14.04-x64-docker.qcow2 for Docker

Brief description of packages located here:

io.murano.apps.docker.kubernetes.KubernetesCluster – represents scalable 
cluster of Kubernetes nodes

io.murano.apps.docker.kubernetes.KubernetesPod – Kubernetes host for Docker 
containers. Several containers may be hosted in single Pod. Also 
automatically manages Service endpoints and replication

io.murano.apps.docker.Interfaces – Interface classes for both Kubernetes and Docker

io.murano.apps.docker.kubernetes.static.KubernetesEntities – Kubernetes 
instances that can be constructed from a JSON definition – Pod, Service 
and ReplicationController

io.murano.apps.docker.DockerStandaloneHost - Docker host on standalone VM

Applications that can be hosted on both Kubernetes Pod and and Docker standalone host:

* io.murano.apps.docker.DockerHTTPd – Apache web server
* io.murano.apps.docker.DockerHTTPdSite – Apache web server with a site pulled from git repository
* io.murano.apps.docker.DockerNginx – Nginx web server
* io.murano.apps.docker.DockerNginxSite – Nginx web server with a site pulled from git repository
* io.murano.apps.docker.DockerCrate - Crate - The Distributed Database for Docker
* io.murano.apps.docker.DockerGlassFish - GlassFish - Java EE 7 Application Server
* io.murano.apps.docker.DockerTomcat - Tomcat - An open-source web server and servlet container
* io.murano.apps.docker.DockerInfluxDB - InfluxDB - An open-source, distributed, time series database
* io.murano.apps.docker.DockerGrafana - Grafana - Metrics dashboard for InfluxDB
* io.murano.apps.docker.DockerJenkins - Jenkins - An extensible open source continuous integration server
* io.murano.apps.docker.DockerMariaDB - MariaDB database
* io.murano.apps.docker.DockerMySQL - MySql database
* io.murano.apps.docker.DockerRedis - Redis - Key-value cache and store
* io.murano.apps.docker.DockerPostgreSQL - PostgreSQL database
* io.murano.apps.docker.DockerMongoDB - MongoDB NoSQL database
* io.murano.apps.docker.DockerPHPZendServer - Zend Server - The Complete PHP Application Platform


