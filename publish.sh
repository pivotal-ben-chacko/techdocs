#!/bin/bash

set -e 

export AWS_ACCESS_KEY_ID=ezzYtqUzA36LFxTbYVkZ
export AWS_SECRET_ACCESS_KEY=dq3Q8adHk6hxvq2hPtu7124lx68bUEKKxr5z5vde
export AWS_REGION=us-east-1

check_tooling () {
  if [ ! command -v techdocs-cli &> /dev/null ]; then
    echo "Unable to continue... Please install techdocs-cli."
    exit 1
  fi
}

generate () {
  techdocs-cli generate --output-dir ./site
}

publish () {
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
