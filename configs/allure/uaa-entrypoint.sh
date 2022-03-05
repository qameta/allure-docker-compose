#!/bin/sh
set -e
apk update
apk add openssl curl consul --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
if [ -z "${TLS_ENDPOINTS}" ]; then
  for i in $(echo "$TLS_ENDPOINTS" | sed "s/,/ /g"); do
    openssl s_client -showcerts -verify 5 -connect "$i" -servername "${i%%:*}" < /dev/null 2> /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print}' > "${i%%:*}".cer
  done
fi
if [ -z "${TLS_DB_ENDPOINTS}" ]; then
  for e in $(echo "$TLS_DB_ENDPOINTS" | sed "s/,/ /g"); do
    openssl s_client -starttls postgres -connect "$e" -showcerts -verify 5 < /dev/null 2> /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print}' > "${e%%:*}".cer
  done
fi
if [ -n "${TLS_ENDPOINTS}" ] || [ ! -z "${TLS_DB_ENDPOINTS}" ]; then
  for cert in *.cer; do
    keytool -alias "${cert%%.cer}" -import -keystore /opt/java/openjdk/lib/security/cacerts -file "$cert" -storepass changeit -noprompt
  done
fi
if [ -z "$CONSUL_DATA_DIR" ]; then
  CONSUL_DATA_DIR=/consul/data
fi
if [ -z "$CONSUL_CONFIG_DIR" ]; then
  CONSUL_CONFIG_DIR=/consul/config
fi
consul agent -data-dir="$CONSUL_DATA_DIR" -config-dir="$CONSUL_CONFIG_DIR" -bind '{{ GetInterfaceIP "eth0" }}' &
java -Djava.security.egd=file:/dev/./urandom -cp /app:/app/lib/* io.qameta.allure.uaa.UaaApplication
