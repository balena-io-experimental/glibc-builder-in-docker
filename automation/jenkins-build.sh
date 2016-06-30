#!/bin/bash

set -o errexit
set -o pipefail

version="2.23"

for arch in $ARCHS; do
	case "$arch" in
		'amd64')
			base_image="resin/amd64-debian:jessie"
		;;
		'i386')
			base_image="resin/i386-debian:jessie"
		;;
		'armv7hf')
			base_image="resin/armv7hf-debian:jessie"
		;;
		'rpi')
			base_image="resin/rpi-raspbian:jessie"
		;;
	esac
	dir=glibc-$arch-alpine-$version

	sed -e s~#{BASE_IMAGE}~$base_image~g Dockerfile.tpl > Dockerfile

	docker build -t glibc-builder .
	docker run --rm -e STDOUT=1 glibc-builder $version /usr/glibc-compat > $dir.tar.gz

	sha256sum $dir.tar.gz > $dir.tar.gz.sha256

	# Upload to S3 (using AWS CLI)
	#printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
	#aws s3 cp $dir.tar.gz s3://$BUCKET_NAME/glibc/$version/
	#aws s3 cp $dir.tar.gz.sha256 s3://$BUCKET_NAME/glibc/$version/
	#rm -rf $dir*
done
