LOCAL_BIN=$(CURDIR)/bin
ifeq ($(wildcard $(LOCAL_BIN)),)
	# Use globally installed dependencies
	LINTER_CMD=golangci-lint
else
	# Use locally installed dependencies
	LOCAL_BIN=$(CURDIR)/bin
	LINTER_CMD=$(LOCAL_BIN)/golangci-lint
endif

env:
	@echo "MOCKERY_CMD: $(MOCKERY_CMD)\nLINTER_CMD: $(LINTER_CMD)"

setup: hooks

hooks:
	chmod u+x $(CURDIR)/pre-commit
	ln -s $(CURDIR)/pre-commit $(shell pwd)/.git/hooks/pre-commit

# ----------------------------------------
# [optional] Binary Dependencies
# ----------------------------------------

bin-deps:
	GOBIN=$(LOCAL_BIN) go install golang.org/x/tools/cmd/goimports@latest
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.56.2
	GOBIN=$(LOCAL_BIN) go install github.com/vektra/mockery/v2@v2.42.0

lint:
	$(LINTER_CMD) run --config=.golangci.yml ./...

clean-deps:
	rm -rf ./bin

# ----------------------------------------
# Code, Docs and Vendor
# ----------------------------------------

source_file=find . -type f \( -name "*.go" ! -regex ! ".*/vendor.*" ! -regex ".mock.*" \)

.PHONY: deps
deps:
	GOPRIVATE=gitlab.com go mod tidy
	GOPRIVATE=gitlab.com go mod download
	GOPRIVATE=gitlab.com go mod vendor

fmt:
	$(source_file) -exec goimports -w -local 'gitlab.com' {} \;