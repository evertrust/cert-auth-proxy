.PHONY: test docker-push docker-build get-version

GIT_CMD         = git
DOCKER_CMD      = docker
IMAGE_NAME      = registry.evertrust.io/cert-auth-proxy
CURRENT_VERSION = $(shell ${MAKE} -s get-version)
DOCKER_PLATFORM = linux/amd64,linux/arm64


get-version: ## Get the current version
	@${GIT_CMD} describe --tags

docker-build:
	docker buildx build --load -t ${IMAGE_NAME}:${CURRENT_VERSION} .

docker-push:
	docker buildx build --push --platform ${DOCKER_PLATFORM} -t ${IMAGE_NAME}:${CURRENT_VERSION} .
	
test: docker-build
	@CONTAINER_ID=$$(docker run -d -p 8443:8443 -e UPSTREAM=example.org:443 -e SSL_VERIFY_CLIENT=optional -v $$(pwd)/test/dummy-certs:/var/cert-auth-proxy/certificates -v $$(pwd)/test/dummy-cas:/var/cert-auth-proxy/trusted-cas ${IMAGE_NAME}:${CURRENT_VERSION}); \
	docker exec $$CONTAINER_ID nginx -t; \
	docker logs $$CONTAINER_ID; \
	docker rm --force $$CONTAINER_ID
	rm -f $$(pwd)/test/dummy-cas/ca-bundle.pem
