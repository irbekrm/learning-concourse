#!/bin/sh

git clone resource-gist updated-gist
cd updated-gist

date > stuff

git config --global user.name "irbekrm"
git config --global user.email "irbekrm@gmail.com"

git add .
git commit -m "Adds date"