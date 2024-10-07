#!/usr/bin/env sh

entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

loaded_certificates=0

if [ -e "$TRUSTED_CAS_LOOKUP_PATH/ca-bundle.pem" ]; then
  entrypoint_log "An existing trusted CAs list has been found in $TRUSTED_CAS_LOOKUP_PATH/ca-bundle.pem. Skipping trusted CAs merge."
  exit 0
fi

while IFS= read -r -d '' x; do
  ca_name=$(basename $x)
  ca_file="${x}/ca.crt"
  if [ ! -e "$ca_file" ]; then
    entrypoint_log "Will NOT be adding $x to the list of trusted CAs because $ca_file is unreadable."
    continue
  fi
  cat $ca_file >> $TRUSTED_CAS_LOOKUP_PATH/ca-bundle.pem
  entrypoint_log "Added $ca_name to the trusted CAs list."
  loaded_certificates=$((loaded_certificates+1))
done < <(find "$TRUSTED_CAS_LOOKUP_PATH" -type d -print0 -maxdepth 1 -mindepth 1)

SSL_VERIFY_CLIENT=$(awk '/ssl_verify_client/ {f=1} f {p=$NF;sub(/;$/,"",p);a[++c]=p} /;$/ {f=0} END {for (i=1;i<=c;i++) print a[i]}' /etc/nginx/nginx.conf)

if [ $loaded_certificates = 0 ]; then
  if [ $SSL_VERIFY_CLIENT = "optional" ] || [ $SSL_VERIFY_CLIENT = "on" ]; then
    echo "No certificate has been found in $TRUSTED_CAS_LOOKUP_PATH/. This is incompatible with ssl_verify_client mode of $SSL_VERIFY_CLIENT. Please use optional_no_ca if you want to allow any CA to be used."
    exit 1
  fi
else
  if [ $SSL_VERIFY_CLIENT = "optional_no_ca" ]; then
    entrypoint_log "Trusted CAs have been found in $TRUSTED_CAS_LOOKUP_PATH/ but ssl_verify_client is set to optional_no_ca. This is incompatible. Please use optional or on."
    exit 1
  fi

  # If we have loaded certificates, we need to set the ssl_client_certificate directive
  echo "ssl_client_certificate ${TRUSTED_CAS_LOOKUP_PATH}/ca-bundle.pem;" >> /etc/nginx/conf.d/trusted-ca-certs.conf
fi