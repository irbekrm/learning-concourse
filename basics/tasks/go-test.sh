#!/bin/sh

set -x

cd urlsh

GO111MODULE=on go test ./...