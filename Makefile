TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/

.PHONY: test test-verbose test-coverage test-help

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }" \
		-c "quit"

test-verbose:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}', verbose = true }" \
		-c "quit"

test-coverage:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}', coverage = true }" \
		-c "quit"

test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make test-file FILE=task_spec"; \
		exit 1; \
	fi
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedFile tests/obsidian-tasks/$(FILE).lua" \
		-c "quit"

test-help:
	@echo "Available test targets:"
	@echo "  test          - Run all tests"
	@echo "  test-verbose  - Run all tests with verbose output"
	@echo "  test-coverage - Run all tests with coverage report"
	@echo "  test-file     - Run specific test file (use FILE=filename)"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make test-verbose"
	@echo "  make test-file FILE=task_spec"
