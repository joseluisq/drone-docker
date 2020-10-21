# Drone Docker Plugin [![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/joseluisq/drone-docker/1)](https://hub.docker.com/r/joseluisq/drone-docker/) [![Build Status](https://travis-ci.com/joseluisq/drone-docker.svg?branch=master)](https://travis-ci.com/joseluisq/drone-docker) [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/joseluisq/drone-docker/1)](https://hub.docker.com/r/joseluisq/drone-docker/tags) [![codecov](https://codecov.io/gh/joseluisq/drone-docker/branch/master/graph/badge.svg)](https://codecov.io/gh/joseluisq/drone-docker) [![Go Report Card](https://goreportcard.com/badge/github.com/joseluisq/drone-docker)](https://goreportcard.com/report/github.com/joseluisq/drone-docker) [![GoDoc](https://godoc.org/github.com/joseluisq/drone-docker?status.svg)](https://godoc.org/github.com/joseluisq/drone-docker)

> [Drone](https://drone.io/) plugin *fork* which uses [Docker-in-Docker](https://www.docker.com/blog/docker-can-now-run-within-docker/) to build and publish **Docker Linux amd64 images only** to a Container Registry. <br>
> This is just a fork for personal use with additional custom features. However you can always refer to [official repository](https://github.com/drone-plugins/drone-docker) uptream.

This repository has made the following changes:

- [Stripped](https://github.com/joseluisq/drone-docker/commit/60874b4314f0fb15c4b214c2ed3ef2a80868f337) all non-Linux amd64 stuff
- Latest Go [v1.15](https://blog.golang.org/go1.15)
- All dependencies up-to-date.
- Added pipelines support for Drone and Travis CI.

## Additional Features

- Auto tag aliases support via `auto_tag_aliases` list that can be used along with `auto_tag`.

_For the original plugin features check out [the drone-plugins docs](http://plugins.drone.io/drone-plugins/drone-docker/)._

### Pipeline example

Note that a [Drone pipeline](https://docs.drone.io/pipeline/overview/) should be configured with `privileged: true`.

```yaml
- name: publish
  image: joseluisq/drone-docker
  pull: always
  # Privileged mode required
  privileged: true
  settings:
    repo: joseluisq/drone-docker
    dockerfile: Dockerfile
    username:
      from_secret: username
    password:
      from_secret: password
    auto_tag: true
    # Additional auto tag aliases
    auto_tag_aliases:
      - latest
```

## Test

```sh
make test
```

## Build

Build the binaries with the following commands:

```sh
make build
```

## Docker

### Build

Build the Docker image with the following commands:

```sh
make image-build
```

### Run

*Notice: Be aware that the Docker plugin currently requires privileged capabilities, otherwise the integrated Docker daemon is not able to start.*

```sh
make image-dryrun
```
