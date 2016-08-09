#!/bin/bash

# $1 - POD NAME AS A PART OF CONTAINER NAME

CONTAINERS=$(docker ps -q --filter "name=_$1-")
if (( ${#CONTAINERS} > 0 )); then
  docker restart "${CONTAINERS}"
fi
