Google Kubernetes for Murano
============================

Packages in this folder are required to deploy both Google Kubernetes and
applications on top of it.

Contents of each folder need to be zipped and uploaded to Murano Catalog.

You will also need to build proper Ubuntu image for Kubernetes.
This can be done using diskimage-builder (https://github.com/openstack/diskimage-builder)
and DIB elements (https://github.com/stackforge/murano/tree/master/contrib/elements/kubernetes).
The image must has name ubuntu14.04-x64-kubernetes.qcow2


Kubernetes is an open-source container manager by Google. It is responsible to
schedule, run and manage docker containers into its own clustered setup.

Kubernetes consists of one or more master nodes running Kubernetes API and
one or more worker nodes (aka minions) that are used to schedule containers.
Containers are aggregated into pods. All containers in single pod are
guaranteed to be scheduled to a single node and share common port space.
Thus it can be considered as a container colocation.

Pods can be replicated. This is achieved by creation of Replication Controller
which creates and maintain fixed number of pod clones. In Murano replica
count is a property of KubernetesPod.

Currently Murano suports setups with only single API node and at least one
worker node. API node cannot be  used as a worker node.

To establish required network connectivity model for the Kubernetes Murano
sets up an overlay network between Kubernetes nodes using Flannel networking.
See https://github.com/coreos/flannel for more information.

Because IP addresses of containers are in that internal network and not
accessible from outside in order to provide public endpoints Murano sets up
a third type of nodes: Gateway nodes.

Gateway nodes are connected to both Flannel and OpenStack Neutron networks
and serves as a gateway between them. Each gateway node runs HAProxy.
When application deploys all its public endpoint are automatically registered
on all gateway nodes. Thus if user chose to have more than one gateway
it will usually get several endpoints for the application. Then those endpoints
can be registered in physical load balancer or DNS.


KubernetesCluster
=================

This is the main application representing Kubernetes Cluster.
It is responsible for deployment of the Kubernetes and its nodes.

The procedure is:

#. Create VMs for all node types - 1 for Kubernetes API and requested number
   for worker and gateway nodes.
#. Join them into etcd cluster. etcd is a distributed key-value storage
   used by the Kubernetes to store and synchronize cluster state.
#. Setup Flannel network over etcd cluster. Flannel uses etcd to track network.
   nodes as well.
#. Configure required services on master node.
#. Configure worker nodes. They will register themselves in master nodes using
   etcd.
#. Setup HAProxy on each gateway node. Configure configd to watch etcd to
   register public ports in HAProxy config file. Each time new Kubernetes
   service created it regenerates HAProxy config.


Internally KubernetesCluster contains separate classes for all node types.
They all inherit from `KubernetesNode` that defines the common interface
for all nodes. The deployment of each node is split into several methods:
`deployInstance` -> `setupEtcd` -> `setupNode` -> `removeFromCluster` as
described above.


KubernetesPod
=============

KubernetesPod represents a single Kubernetes pod with its containers and
associated volumes. KubernetesPod provides an implementation of
`DockerContainerHost` interface defined in `DockerInterfacesLibrary`.
Thus each pod can be used as a drop-in replacement for regular Docker
host implementation (DockerStandaloneHost).

All pods must have a unique name within single `KubernetesCluster`
(which is selected for each pod).

Thus KubernetesCluster is an aggregation of Docker hosts (pods) which also
handles all inter-pod entities (services, endpoints).

KubernetesPod create Replication Controllers rather than pods. Replication
Controller with replica count equal to 1 will result in single pod being
created while it is always possible to increase/decrease replica count after
deployment. Replica count is specified using `replicas` input property.

Pods also may have labels to group them (for example into layers etc.)


Kubernetes actions
==================

Both KubernetesCluster and KubernetesPod expose number of actions that can
be used by both user (through the dashboard) and automation systems (through
API) to perform actions on the deployed applications.

See http://docs.openstack.org/developer/murano/draft/appdev-guide/murano_pl.html#murano-actions
and http://docs.openstack.org/developer/murano/specification/index.html#actions-api
for more details on actions API.

KubernetesCluster provides the following actions:

* `scaleNodesUp`: increase the number of worker nodes by 1.
* `scaleNodesDown`: decrease the number of worker nodes by 1.
* `scaleGatewaysUp`: increase the number of gateway nodes by 1.
* `scaleGatewaysDown`: decrease the number of gateway nodes by 1.
* `exportConfig`: returns an archive file containing shell script and data
  files. Use the script to manually recreate Kubernetes entities (pods,
  replication controllers and services) on another Kubernetes installation.
  This is an experimental feature.

KubernetesPod has the following actions:

* `scalePodUp`: increase the number of pod replicas by 1.
* `scalePodDown`: decrease the number of pod replicas by 1.
