.PHONY: test

IMAGE_NAME = cert-auth-proxy
TEST_IMAGE_TAG = test


get-version:
	
test:
	docker build . -t $(IMAGE_NAME):$(TEST_IMAGE_TAG)
	@IMAGE_ID=$$(docker run -d -p 8443:8443 -e UPSTREAM=example.org:443 -e SSL_VERIFY_CLIENT=optional -v $$(pwd)/test/dummy-certs:/var/cert-auth-proxy/certificates -v $$(pwd)/test/dummy-cas:/var/cert-auth-proxy/trusted-cas $(IMAGE_NAME):$(TEST_IMAGE_TAG)); \
	docker exec $$IMAGE_ID nginx -t; \
	docker stop $$IMAGE_ID; \
	docker logs $$IMAGE_ID; \
	docker rm $$IMAGE_ID
	docker image rm $(IMAGE_NAME):$(TEST_IMAGE_TAG)
	rm -f $$(pwd)/test/dummy-cas/ca-bundle.pem
