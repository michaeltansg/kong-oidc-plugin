# Define the command to use for Docker Compose based on system availability
DOCKER_COMPOSE_CMD=$(if $(shell command -v docker-compose 2> /dev/null),docker-compose,docker compose)

kong-custom-oidc:
	docker build -t kong-custom-oidc:latest -f Dockerfile.linux.arm64 .

start:
	COMPOSE_PROJECT_NAME=gateway KONG_DOCKER_TAG=kong-custom-oidc $(DOCKER_COMPOSE_CMD) -f docker-compose.openwebui.yml up -d

# For development purposes
restart:
	docker restart kong

# For development purposes
renew: remove-kong-container kong-custom-oidc start

remove-kong-container:
	docker stop kong
	docker rm kong

kong-shell:
	docker exec -u root -it kong /bin/bash

push:
	source .env.repo && \
	docker buildx build --platform $$PLATFORM -t $$REPO_NAME/$$IMAGE_NAME:$$TAG --pull --no-cache --push .