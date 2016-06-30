#!/bin/bash

set -o errexit
set -o pipefail

version="2.23"

for arch in $ARCHS; do
	case "$arch" in
		'amd64')
			base_image="resin/amd64-debian:jessie"
			extra_flags=""
		;;
		'i386')
			base_image="resin/i386-debian:jessie"
			extra_flags="--build=x86_64-pc-linux-gnu --host=i686-pc-linux-gnu"
		;;
		'armv7hf')
			base_image="resin/armv7hf-debian:jessie"
			extra_flags=""
		;;
		'rpi')
			base_image="resin/rpi-raspbian:jessie"
			extra_flags=""
		;;
	esac
	dir=glibc-$arch-alpine-$version

	sed -e s~#{BASE_IMAGE}~$base_image~g Dockerfile.tpl > Dockerfile

	docker build -t glibc-builder .
	docker run --rm -e STDOUT=1 -e EXTRA_FLAGS="$extra_flags" glibc-builder $version /usr/glibc-compat > $dir.tar.gz

	sha256sum $dir.tar.gz > $dir.tar.gz.sha256

	# Upload to S3 (using AWS CLI)
	#printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
	#aws s3 cp $dir.tar.gz s3://$BUCKET_NAME/glibc/$version/
	#aws s3 cp $dir.tar.gz.sha256 s3://$BUCKET_NAME/glibc/$version/
	#rm -rf $dir*
done
