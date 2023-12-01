SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

DOCKER_RUN ?= docker compose run --rm

init: install storage  ## Setup your local environment for the first time.
	cp .env.sample .env
.PHONY: init

install:  ## Install the project and its dependencies.
	brew install scarvalhojr/tap/aoc-cli
	curl -sSL https://install.python-poetry.org | python3 -
	poetry install
.PHONY: install


storage:  ## Spin up the storage backend.
	docker compose up --build -d
.PHONY: storage

nuke-storage:
	docker compose down -v --rmi all
	docker volume rm aoc-2022_database
.PHONY: nuke-storage

migrate-up:  ## Run any pending migrations.
	$(DOCKER_RUN) aoc-migrations deploy
.PHONY: migrate-up

migrate-down:  ## Revert any modified migrations so we can re-apply them.
	$(DOCKER_RUN) aoc-migrations revert --modified
.PHONY: migrate-down


name ?=
comment ?=
require ?=

new-migration:  ## Make a new migration. Required Arguments: `name=<name>`, `comment=<comment>`, `require=<require>`
	$(DOCKER_RUN) aoc-migrations add "$(name)" --require "$(require)" -m "$(comment)"
	git add db
.PHONY: new-migration


verify-migration:  ## Make a new migration. Required Arguments: `name=<name>`
	$(DOCKER_RUN) aoc-migrations verify "$(name)"
.PHONY: verify-migration


day ?= 1
part ?= 1

puzzle:  ## Get the puzzle for the targeted day. Arguments: `day=<day|1>`, `part=<part|1>`.
	cp -R "day/.template" "day/$(day)"
	chmod +x "day/$(day)/solve.py"
	aoc download --day=$(day) --input-file="day/$(day)/input" --puzzle-file="day/$(day)/puzzle.md" --overwrite
	aoc read --day=$(day)
	git add "day/$(day)/"
.PHONY: puzzle


solve: storage  ## Run the solution for the targeted day. Arguments: `day=<day|1>`
	poetry run ./day/$(day)/solve.py
.PHONY: solve

submit: storage  ## Run the solution for the targeted day and submit it to AOC for the targeted part. Arguments: `day=<day|1>`, `part=<part|1>`.
	aoc submit --day=$(day) $(part) $(shell poetry run ./day/$(day)/solve.py)
.PHONY: submit

help:  ## Display this help screen.
	@printf "\n$(ITALIC)$(GREEN)Supported Commands: $(RESET)\n"
	@grep -E '^[a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(CYAN)$(MSGPREFIX) %-$(MAX_CHARS)s$(RESET) $(ITALIC)$(DIM)%s$(RESET)\n", $$1, $$2}'

.PHONY: help
.DEFAULT_GOAL := help

# Messaging
MAX_CHARS ?= 24
BOLD := \033[1m
RESET_BOLD := \033[21m
ITALIC := \033[3m
RESET_ITALIC := \033[23m
DIM := \033[2m
BLINK := \033[5m
RESET_BLINK := \033[25m
RED := \033[1;31m
GREEN := \033[32m
YELLOW := \033[1;33m
MAGENTA := \033[1;35m
CYAN := \033[36m
RESET := \033[0m
MSGPREFIX ?=   »
