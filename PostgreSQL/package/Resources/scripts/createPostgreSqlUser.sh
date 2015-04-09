#!/bin/bash

sudo -u postgres psql -c "CREATE USER $1 WITH PASSWORD '$2'"
