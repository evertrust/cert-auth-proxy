#!/usr/bin/env sh

entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

loaded_certificates=0

while IFS= read -r -d '' x; do
  domain_name=$(basename $x)
  cert_file="${x}/tls.crt"
  key_file="${x}/tls.key"
  if [ -e "$cert_file" ] && [ -e "$key_file" ]; then
    entrypoint_log "Will be serving $domain_name because certificate $cert_file has been found."
    loaded_certificates=$((loaded_certificates+1))
  else
    entrypoint_log "Will NOT be serving $domain_name because either $cert_file or $key_file is unreadable."
  fi
done < <(find "$CERTIFICATES_LOOKUP_PATH" -type d -print0 -maxdepth 1 -mindepth 1)

if [ $loaded_certificates = 0 ]; then
  echo "No certificate has been found in $CERTIFICATES_LOOKUP_PATH. Please mount some and restart the container."
  exit 1
else
  echo "Loaded $loaded_certificates certificates."
fi
