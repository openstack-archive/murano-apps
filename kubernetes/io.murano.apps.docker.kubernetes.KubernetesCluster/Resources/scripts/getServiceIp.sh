#!/bin/bash

/opt/bin/kubectl get service $1 -t '{{.portalIP}}' -o template