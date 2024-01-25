FROM nginx:1-alpine

COPY config/nginx.conf /etc/nginx/
COPY certs/dummy-root-ca.pem /var/cert-auth-proxy/trusted-cas/
COPY docker-entrypoint.d/40-envsubst-on-nginx-conf.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/50-check-for-mounted-certificates.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/60-merge-trusted-cas.sh /docker-entrypoint.d/

ENV BASE_DATA_PATH "/var/cert-auth-proxy"

# Create a directory for the certificates to be mounted into
ENV CERTIFICATES_LOOKUP_PATH "$BASE_DATA_PATH/certificates"
RUN mkdir -p $CERTIFICATES_LOOKUP_PATH

# Create a directory for the trusted CAs to be mounted into
ENV TRUSTED_CAS_LOOKUP_PATH "$BASE_DATA_PATH/trusted-cas"
RUN mkdir -p $TRUSTED_CAS_LOOKUP_PATH