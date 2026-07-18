#!/bin/bash
./bin/pg_ctl restart -D ./data
read -n1 -r -p "" key
