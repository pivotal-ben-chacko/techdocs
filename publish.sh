#!/bin/bash

set -e 

check_tooling () {
  if [ ! command -v techdocs-cli &> /dev/null ]; then
    echo "Unable to continue... Please install techdocs-cli."
    exit 1
  fi
}

generate () {
  techdocs-cli generate --no-docker --output-dir ./site
}

publish () {
  echo "DEBUG: $AWS_ACCESS_KEY_ID"
  techdocs-cli publish 	--publisher-type awsS3 \
   			--awsEndpoint https://minio-api.skynetsystems.io \
			--storage-name techdocs \
			--entity default/Component/onboarding \
			--awsS3ForcePathStyle \
			--directory ./site
}

init () {
  check_tooling
  generate
  publish
}

init
