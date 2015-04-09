#!/bin/bash

sudo -u postgres psql -c "CREATE DATABASE $1"
