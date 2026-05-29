.PHONY: dev build lint test

dev:
	@cp -n .env.example .env 2>/dev/null || true
	go run ./cmd/server

build:
	CGO_ENABLED=0 go build -o umetter ./cmd/server

lint:
	go vet ./...

test:
	go test ./...
