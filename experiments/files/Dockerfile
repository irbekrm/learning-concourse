FROM ubuntu:bionic AS builder
RUN apt-get update && \
  apt-get install -y --no-install-recommends jq

FROM builder