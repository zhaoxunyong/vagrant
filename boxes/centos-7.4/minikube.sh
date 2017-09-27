#!/bin/sh

minikube start --docker-env HTTP_PROXY=http://192.168.0.106:1080 --docker-env HTTPS_PROXY=http://192.168.0.106:1080
