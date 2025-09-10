TESTS_DIR ?= ".tmp/tests"
TESTS_BRANCH ?= "staging"
IMAGE_TAG ?= "staging"	

all: import build

build:
	./build.sh master $(IMAGE_TAG) --tests-dir $(TESTS_DIR)

import: clean
	./import-tests.sh --tests-branch $(TESTS_BRANCH)

clean:
	rm -rf .tmp
