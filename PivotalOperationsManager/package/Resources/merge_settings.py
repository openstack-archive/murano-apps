#!/usr/bin/python

import json
from copy import deepcopy

fileName1 = "/tmp/murano/bare-installation.yml"
fileName2 = "/tmp/murano/user-installation.yml"


def load_data(fname):
    with open(fname, "r") as f:
        return json.load(f)


def dict_merge(target, data):
    # Recursively merge dicts and set non-dict values
    obj = data
    if not isinstance(obj, dict):
        return obj
    for k, v in obj.iteritems():
        if k in target and isinstance(target[k], dict):
            dict_merge(target[k], v)
        else:
            target[k] = deepcopy(v)
    return target

bare_data = load_data(fileName1)
user_data = load_data(fileName2)

target = dict_merge(bare_data, user_data)

try:
    target["products"][0]["singleton_availability_zone_reference"] = \
        target["infrastructure"]["availability_zones"][0]["guid"]
    target["products"][0]["infrastructure_network_reference"] = \
        target["infrastructure"]["networks"][0]["guid"]
    target["products"][0]["deployment_network_reference"] = \
        user_data["infrastructure"]["networks"][0]["guid"]

except Exception as e:
    logf = open("/tmp/murano/ops-config.log", "w")
    logf.write("Unable to assign network/azone: {0}".format(str(e)))

with open("/tmp/murano/installation.yml", "w") as dest_file:
    json.dump(target, dest_file)