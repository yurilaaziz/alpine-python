#VARS
DOCKER_IMAGE_PREFIX=$(DOCKER_REGISTRY_USER)
DOCKER_BUILD_OPTIONS=


DOCKER_IMAGE_NAME=python$(DOCKER_IMAGE_VERSION)$(DOCKER_OS_ARCH)
PYTHON_MAKE_OPTIONS=
DOCKER_BUILD_ARGS:=

ifndef CI_BUILD_NUMBER
	CI_BUILD_NUMBER:=0
endif


ifdef ARCH
	DOCKER_OS_ARCH:=-$(ARCH)
endif
ifdef PYTHON_VERSION
	PYTHON_VERSION_ARRAY:= $(subst ., ,$(PYTHON_VERSION))
	PYTHON_VERSION_MAJOR:=$(word 1,$(PYTHON_VERSION_ARRAY))
	PYTHON_VERSION_MINOR:=$(word 2,$(PYTHON_VERSION_ARRAY))
	PYTHON_VERSION_FIX:=$(word 3,$(PYTHON_VERSION_ARRAY))
	DOCKER_IMAGE_VERSION:=$(PYTHON_VERSION_MAJOR).$(PYTHON_VERSION_MINOR)
	DOCKER_IMAGE_TAG:=$(PYTHON_VERSION_FIX)
else
	DOCKER_IMAGE_VERSION:=3-all
endif

ifndef DOCKER_IMAGE_TAG
	DOCKER_IMAGE_TAG:="untagged"
endif

ifdef PYTHON_VERSION
	DOCKER_BUILD_ARGS:=$(DOCKER_BUILD_ARGS) --build-arg python_version=$(PYTHON_VERSION)
endif
ifdef PYTHON_MAKE_OPTIONS
	DOCKER_BUILD_ARGS:=$(DOCKER_BUILD_ARGS) --build-arg python_make_options=$(PYTHON_MAKE_OPTIONS)
endif


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# docker TASKS
# Build the container
build: ## Build the container
	docker build -t $(DOCKER_IMAGE_NAME) $(DOCKER_BUILD_OPTIONS) $(DOCKER_BUILD_ARGS) .

build-nc: ## Build the container without caching
	docker build --no-cache  -t $(DOCKER_IMAGE_NAME) $(DOCKER_BUILD_OPTIONS) $(DOCKER_BUILD_ARGS) .

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers 

# docker publish
publish: docker-login publish-version publish-latest ## Publish the `{version}` ans `latest` tagged containers

publish-latest: tag-latest ## Publish the `latest` taged container 
	@echo 'publish latest to $(DOCKER_IMAGE_PREFIX)'
	docker push $(DOCKER_IMAGE_PREFIX)/$(DOCKER_IMAGE_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container 
	@echo 'publish $(DOCKER_IMAGE_NAME) to $(DOCKER_IMAGE_PREFIX)/$(DOCKER_IMAGE_NAME)'
	docker push $(DOCKER_IMAGE_PREFIX)/$(DOCKER_IMAGE_NAME)

# docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `latest` tag
	@echo 'create tag latest'
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_IMAGE_PREFIX)/$(DOCKER_IMAGE_NAME):latest

tag-version: ## Generate container `{version}` tag
	@echo 'create tag $(DOCKER_IMAGE_NAME)'
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_IMAGE_PREFIX)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_IMAGE_PREFIX)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)-$(CI_BUILD_NUMBER)


# login to Dcoker Hub
docker-login: ## Auto login to Docker Hub
	echo $(DOCKER_REGISTRY_PASSWORD) | docker login -u $(DOCKER_REGISTRY_USER) --password-stdin

version: ## Output the current version
	@echo $(DOCKER_IMAGE_NAME)

