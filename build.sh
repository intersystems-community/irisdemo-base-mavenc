#!/bin/bash
VERSION=`cat ./VERSION`

docker build -t intersystemsdc/irisdemo-base-mavenc:version-$VERSION .
