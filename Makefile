LABEL_SCHEMA_BUILD_DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LABEL_SCHEMA_VCS_REF ?= $(shell git rev-parse --short HEAD)

test:
	@go test -v -timeout 30s -race -coverprofile=coverage.txt -covermode=atomic ./...
.PHONY: test

coverage:
	@bash -c "bash <(curl -s https://codecov.io/bash)"
.PHONY: coverage

fmt:
	@go fmt ./...
.PHONY: fmt

build:
	@go build -v -a -tags netgo -o release/linux/amd64/drone-docker ./cmd
.PHONY: build

build-image:
	@docker build \
		--label org.label-schema.build-date=$(LABEL_SCHEMA_BUILD_DATE) \
		--label org.label-schema.vcs-ref=$(LABEL_SCHEMA_VCS_REF) \
		--file docker/docker/Dockerfile.linux.amd64 \
		--tag plugins/docker .
.PHONY: build-image

drone-generate:
	@drone jsonnet --stream
.PHONY: drone-generate
