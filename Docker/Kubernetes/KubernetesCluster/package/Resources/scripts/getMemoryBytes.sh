#!/bin/bash

vmstat -s -SB | head -n1 | grep "[0-9]*" -o