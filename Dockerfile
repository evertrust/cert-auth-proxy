FROM nginxinc/nginx-unprivileged:1-alpine

USER root

COPY config/nginx.conf /etc/nginx/
COPY config/trusted-ca-certs.conf /etc/nginx/conf.d/

COPY docker-entrypoint.d/40-envsubst-on-nginx-conf.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/50-check-for-mounted-certificates.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/60-merge-trusted-cas.sh /docker-entrypoint.d/

ENV BASE_DATA_PATH="/var/cert-auth-proxy"

# Create a directory for the certificates to be mounted into
ENV CERTIFICATES_LOOKUP_PATH="$BASE_DATA_PATH/certificates"
RUN mkdir -p $CERTIFICATES_LOOKUP_PATH

# Create a directory for the trusted CAs to be mounted into
ENV TRUSTED_CAS_LOOKUP_PATH="$BASE_DATA_PATH/trusted-cas"
RUN mkdir -p $TRUSTED_CAS_LOOKUP_PATH

RUN chown -R $UID:0 /var/cert-auth-proxy &&  \
    chmod -R g=u /var/cert-auth-proxy

USER $UID

