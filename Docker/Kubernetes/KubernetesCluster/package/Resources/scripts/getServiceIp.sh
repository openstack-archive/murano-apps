#!/bin/bash

/opt/bin/kubectl get service $1 --template '{{.spec.clusterIP}}' -o template
