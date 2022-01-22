#!/bin/sh

mkdir -p "$(pwd)/certs"
openssl dhparam -out "$(pwd)/certs/dhparam.pem" 4096
