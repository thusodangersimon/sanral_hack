.PHONY: create-image \
	create-container \
	run-container \
	run-shell-container \
	remove-container \
	remove-image \
	remove-all \
	create-all \
	clean-pyc \
	clean \
	lint \
	test_environment


#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME = sanral-uber
PYTHON_INTERPRETER = python3

export DOCKER=docker
export PWD=`pwd`

export DEV_IMAGE_NAME=$(PROJECT_NAME)_image

export DEV_CONTAINER_NAME=$(PROJECT_NAME)_container


export DEV_DOCKERFILE=Dockerfile


export JUPYTER_HOST_PORT=8888
export JUPYTER_CONTAINER_PORT=8888


#################################################################################
# COMMANDS                                                                      #
#################################################################################


#####


## Create a docker image in the dev environment.
create-image:
	-$(DOCKER) build -t $(DEV_IMAGE_NAME) -f $(DEV_DOCKERFILE) .


## Create a docker container in the dev environment.
create-container:
	-$(DOCKER) run -it -v $(PWD):/home/jovyan/ -p $(JUPYTER_HOST_PORT):$(JUPYTER_CONTAINER_PORT) -p 5000:5000 --name $(DEV_CONTAINER_NAME) $(DEV_IMAGE_NAME)

## Run the previous docker container in the dev environment.
run-container:
	-$(DOCKER) container start -ia $(DEV_CONTAINER_NAME)

## Gain access to a shell in the docker container in the dev environment.
run-shell-container:
	-$(DOCKER) exec -i -t $(DEV_CONTAINER_NAME) /bin/bash


## Remove the docker container in the dev environment.
remove-container:
	-$(DOCKER) container stop $(DEV_CONTAINER_NAME)
	-$(DOCKER) container rm $(DEV_CONTAINER_NAME)


## Remove the docker image in the dev environment.
remove-image:
	-$(DOCKER) image rm $(DEV_IMAGE_NAME)


## Create a docker image and container in the dev environment.
create-all: create-image create-container


## Remove the docker container and image in the dev environment.
remove-all: remove-container remove-image


#####


## Clean all compiled Python files.
clean-pyc:
	-find . -type f -name "*.py[co]" -delete
	-find . -type d -name "__pycache__" -delete


## Clean all files, and remove the docker container and image in both the dev and prod environments.
clean: clean-pyc dev-remove-all prod-docker-remove


## Lint using flake8.
lint:
	-flake8 src


## Test that the Python environment is set up correctly.
test_environment:
	-$(PYTHON_INTERPRETER) test_environment.py


#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
