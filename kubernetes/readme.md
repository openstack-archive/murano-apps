# Google Kubernetes for Murano

Packages in this folder are required to deploy both Google Kubernetes and applications 
on top of it.

Contents of each folder need to be zipped and uploaded to Murano Application Catalog. 
You will also need to build proper Ubuntu image for Kubernetes. 
This can be done using diskimage-builder (https://github.com/openstack/diskimage-builder) and 
DIB elements (https://github.com/stackforge/murano/tree/master/contrib/elements/kubernetes).

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

io.murano.apps.docker.DockerHTTPd – Apache web server in Docker container that can be 
hosted on Kubernetes
