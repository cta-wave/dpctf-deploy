TESTS_DIR ?= ".tmp/tests"
TESTS_BRANCH ?= "v4.0.0"
RUNNER_DIR ?= ".tmp/runner"
RUNNER_BRANCH ?= "v4.0.0"
CONTENT_VERSION ?= "v4.0.0"
IMAGE_TAG ?= "v4.0.0"	
IMAGE_NAME ?= "dpctf"

all: build import-content

build: import-runner import-tests build-tr
	
build-tr:
	./build.sh $(IMAGE_NAME) $(IMAGE_TAG) --tests-dir $(TESTS_DIR) --runner-dir $(RUNNER_DIR)

import-tests:
	./import-tests.sh --tests-branch $(TESTS_BRANCH)
	
import-runner:
	./import-runner.sh --branch $(RUNNER_BRANCH)

import-content:
	./import-content.sh $(CONTENT_VERSION)

clean:
	rm -rf .tmp
