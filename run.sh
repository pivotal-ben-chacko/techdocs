#!/bin/bash

set -e 

git clone $GIT_URL
cd techdocs

./publish.sh
