#!/usr/bin/env sh

subst_var() {
  escaped_var=$(printf '%s\n' "$2" | sed -e 's/[\/&]/\\&/g')
  sed -i "s/\${$1}/$escaped_var/" /etc/nginx/nginx.conf
}

# Check that an upstream server is set
if [ -z "$UPSTREAM" ]; then
  echo "The \$UPSTREAM environment variable must be specified."
    exit 1
fi
subst_var "UPSTREAM" $UPSTREAM

# Default forwarded header name
if [ -z "$FORWARDED_HEADER_NAME" ]; then
    FORWARDED_HEADER_NAME="X-Forwarded-Tls-Client-Cert"
fi
subst_var "FORWARDED_HEADER_NAME" $FORWARDED_HEADER_NAME

# Default client verify value
if [ -z "$SSL_VERIFY_CLIENT" ]; then
    SSL_VERIFY_CLIENT="optional_no_ca"
fi
subst_var "SSL_VERIFY_CLIENT" $SSL_VERIFY_CLIENT

# Default listen address
if [ -z "$LISTEN" ]; then
    LISTEN="8443"
fi
subst_var "LISTEN" $LISTEN

subst_var "TRUSTED_CAS_LOOKUP_PATH" $TRUSTED_CAS_LOOKUP_PATH
subst_var "CERTIFICATES_LOOKUP_PATH" $CERTIFICATES_LOOKUP_PATH