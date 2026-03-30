TESTS_DIR ?= ".tmp/tests"
TESTS_BRANCH ?= "v4.0.0"
RUNNER_DIR ?= ".tmp/runner"
RUNNER_BRANCH ?= "v4.0.0"
IMAGE_TAG ?= "v4.0.0"	
IMAGE_NAME ?= "dpctf"

all: import-runner import-tests build

build:
	./build.sh $(IMAGE_NAME) $(IMAGE_TAG) --tests-dir $(TESTS_DIR) --runner-dir $(RUNNER_DIR)

import-tests:
	./import-tests.sh --tests-branch $(TESTS_BRANCH)
	
import-runner:
	./import-runner.sh --branch $(RUNNER_BRANCH)

clean:
	rm -rf .tmp
