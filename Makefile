# Single platform build (local testing)
build:
	docker build -t nodedock:latest .

# Multi-platform build and push
build-push:
	docker buildx build --platform linux/amd64,linux/arm64 -t nodedock:latest --push .

# Run locally
run:
	docker compose up -d

# Stop
stop:
	docker compose down

# Rebuild and run
rebuild:
	docker compose up -d --build

# View logs
logs:
	docker compose logs -f web

# Build the static site
build-site:
	docker compose exec web npm run build

# Install dependencies
install:
	docker compose exec web npm install

# Shell access
shell:
	docker compose exec web bash

# Clean everything
clean:
	docker compose down -v
	docker rmi nodedock:latest 2>/dev/null || true

.PHONY: build build-push run stop rebuild logs build-site install shell clean
