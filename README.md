# Drone Docker Plugin [![Build Status](https://travis-ci.com/joseluisq/drone-docker.svg?branch=master)](https://travis-ci.com/joseluisq/drone-docker) [![codecov](https://codecov.io/gh/joseluisq/drone-docker/branch/master/graph/badge.svg)](https://codecov.io/gh/joseluisq/drone-docker) [![Go Report Card](https://goreportcard.com/badge/github.com/joseluisq/drone-docker)](https://goreportcard.com/report/github.com/joseluisq/drone-docker) [![GoDoc](https://godoc.org/github.com/joseluisq/drone-docker?status.svg)](https://godoc.org/github.com/joseluisq/drone-docker)

> [Drone](https://drone.io/) plugin *fork* which uses [Docker-in-Docker](https://www.docker.com/blog/docker-can-now-run-within-docker/) to build and publish **Docker Linux amd64 images only** to a Container Registry.
> This is just a fork for personal use, so please refer to [official repository](https://github.com/drone-plugins/drone-docker) uptream.

## Test

```sh
make test
```

## Build

Build the binaries with the following commands:

```sh
export GOOS=linux
export GOARCH=amd64
export CGO_ENABLED=0
export GO111MODULE=on

go build -v -a -tags netgo -o release/linux/amd64/drone-docker ./cmd/drone-docker
```

## Image

Build the Docker images with the following commands:

```sh
docker build \
  --label org.label-schema.build-date=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --label org.label-schema.vcs-ref=$(git rev-parse --short HEAD) \
  --file docker/docker/Dockerfile.linux.amd64 \
  --tag plugins/docker .
```

## Run

*Notice: Be aware that the Docker plugin currently requires privileged capabilities, otherwise the integrated Docker daemon is not able to start.*

```sh
docker run --rm \
  -e PLUGIN_TAG=latest \
  -e PLUGIN_REPO=octocat/hello-world \
  -e DRONE_COMMIT_SHA=d8dbe4d94f15fe89232e0402c6e8a0ddf21af3ab \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  --privileged \
    plugins/docker --dry-run
```
