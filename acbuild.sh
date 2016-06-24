#!/usr/bin/env bash
set -e

os=linux
version=0.0.1
arch=amd64

acbuildend () {
    export EXIT=$?;
    rm -f inspector
    acbuild --debug end && exit $EXIT;
}

acbuild --debug begin
trap acbuildend EXIT

GOOS="${os}"
GOARCH="${arch}"

CGO_ENABLED=0 go build

acbuild set-name s-urbaniak.github.io/rkt8s-workshop/image/inspector
acbuild copy inspector /inspector
acbuild copy css /css
acbuild set-exec /inspector
acbuild port add www tcp 8080
acbuild label add version "${version}"
acbuild label add arch "${arch}"
acbuild label add os "${os}"
acbuild annotation add authors "Sergiusz Urbaniak <sergiusz.urbaniak@gmail.com>"
acbuild write --overwrite inspector-"${version}"-"${os}"-"${arch}".aci

gpg --yes --batch \
    -u sergiusz.urbaniak@gmail.com \
    --armor \
    --output inspector-0.0.1-linux-amd64.aci.asc \
    --detach-sign inspector-0.0.1-linux-amd64.aci
