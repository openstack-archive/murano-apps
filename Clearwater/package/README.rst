Clearwater vIMS Murano Package
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Clearwater is an open source implementation of IMS (the IP Multimedia
Subsystem) designed from the ground up for massively scalable deployment
in the Cloud to provide voice, video and messaging services to millions
of users. Clearwater combines the economics of over-the-top style service
platforms with the standards compliance expected of telco-grade communications
network solutions, and its Cloud-oriented design makes it extremely
well suited for deployment in a
Network Functions Virtualization (NFV) environment.

*Requirements*

* Ubuntu 14.04 image with cloudinit
* Tenant must be able to spawn 7 VMs with minimum requirements: 2GB RAM, 1 VCPU

*How to connect Softphone application to Clearwater environment*

* Find `Ellis` IP in environment deployment log, open Ellis's floating IP in new tab
* Create new user via Ellis interface (secret code: secret)
* Create new profile in Softphone app, use Private Identity account data
* Use outbound proxy IP from environment deployment log
* Use TCP transport

*How to run live tests*

* Checkout `https://github.com/Metaswitch/clearwater-live-test`_ repo
* Install pre-requisites
* Run `rake test[<DNS ZONE NAME>] SIGNUP_CODE=secret TRANSPORT=TCP PROXY=<OUTBOUND PROXY IP> ELLIS=<ELLIS IP>`