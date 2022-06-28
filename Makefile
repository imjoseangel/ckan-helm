# Current version
# VERSION ?= 1.0.3

.DEFAULT_GOAL:=help

PATH  := $(PATH):$(PWD)/bin
OS    = $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  = $(shell uname -m | sed 's/x86_64/amd64/')
OSOPER   = $(shell uname -s | tr '[:upper:]' '[:lower:]' | sed 's/darwin/apple-darwin/' | sed 's/linux/linux-gnu/')
ARCHOPER = $(shell uname -m )

.PHONY: help

help:  ## Display this help

	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

all: build

.PHONY: build
build: ## Build Helm
		$(info Make: Build Helm)
		@helm package dependency-charts/datapusher/
		@helm package .
		@mkdir -p docs
		@mv *.tgz docs/

chart: ## Build Chart
		$(info Make: Build Chart)
		@helm repo index --url https://imjoseangel.eu/ckan-helm/ docs/

merge: ## Merge Chart
		$(info Make: Merge Chart)
		@helm repo index --url https://imjoseangel.eu/ckan-helm/ --merge index.yaml docs/

lint: ## Lint Chart
		$(info Make: Lint Chart)
		@helm lint .

buildx: ## Build Dockerfile
		$(info Make: Build Dockerfile)
		@docker buildx create --name buildx --driver-opt network=host --use
		@docker buildx inspect --bootstrap
		@docker buildx build -t imjoseangel/ckan:0.0.1 --platform linux/amd64 --platform linux/arm64 --file Dockerfile --push .
		@docker buildx imagetools inspect imjoseangel/ckan:0.0.1
		@docker buildx rm buildx
