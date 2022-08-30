# Allure TestOps ENV Reference

```dotenv
# Sets Testops Version
ALLURE_VERSION=X.Y.Z

# Sets Domain for your TestOps deployment. Affects CORS
ALLURE_HOST=domain.tld

# Port to expose TestOps. We suggest using 8080 and then using External LoadBalancer like Nginx
# HAProxy, Envoy...
ALLURE_INSTANCE_PORT=80

# Should be same with External LoadBalancer
ALLURE_PROTO=http

# Session duration in seconds. When session gets expired, user will be logged out.
ALLURE_SESSION_DURATION=57600

# Should be the same as in Postgres and other services
TZ="Europe/London"

# Admin's Username.
ALLURE_ADMIN=admin

# Admin's Password. To reset pass, replace pass and restart testops
ALLURE_ADMIN_PASS=password

# JWT secret, used to sign JWT tokens. If you rewrite it, all issued JWTs will be invalid
ALLURE_JWT_SECRET=<SET_YOUR_SECRET_HERE>

# This parameter's value is used to encrypt sensitive data in the database. Losing this will require re-creation of all sensitive data.
ALLURE_CRYPTO_PASSWORD=<SET_YOUR_SECRET_HERE>

# Enables http-only cookie parameter. Enable only if you use https otherwise auth will not work
ALLURE_SECURE_COOKIE=false

# Docker Registry where you pull images. Usually it's your company's nexus or artifactory
ALLURE_REGISTRY=docker.io

# Slug e.g. dl.qameta.io/${ALLURE_SLUG}/allure-gateway:${VERSION}
ALLURE_SLUG=allure

# Port for Gateway Component. Do not change
ALLURE_GATEWAY_PORT=8080

## REDIS
# Required to store all sessions. Used by Gateway Component Only

# Host 
# compose
ALLURE_REDIS_HOST=redis
# hostname
ALLURE_REDIS_HOST=redis.example.com
# IP
ALLURE_REDIS_HOST="192.168.10.63"

# Port
ALLURE_REDIS_PORT=6379
# Pass
ALLURE_REDIS_PASS=Y5ZBqrcb68WKA9ZZ

## UAA

# Lets Postgres identify UAA Service
ALLURE_UAA_SERVICE_NAME=allure-uaa-service

# UAA Context Path. Please DO NOT CHANGE
ALLURE_UAA_CONTEXT_PATH=/uaa

# UAA Port, DO NOT CHANGE
ALLURE_UAA_PORT=8082

# Postgres Host
# Compose
ALLURE_UAA_DB_HOST=uaa-db
# hostname
ALLURE_UAA_DB_HOST=pg.example.com
# IP
ALLURE_UAA_DB_HOST="192.168.10.64"

# UAA Database Name
ALLURE_UAA_DB_NAME=uaa

# UAA Database user/role
ALLURE_UAA_DB_USERNAME=uaa

# UAA Database pass
ALLURE_UAA_DB_PASS=<IDontReadDocs>

# UAA Database Port
ALLURE_UAA_DB_PORT=5432

# Enable SignUp on Login page
ALLURE_REGISTRATION_ENABLED=false

# Don't need to approve new users if true
ALLURE_REGISTRATION_AUTOAPPROVE=false

## Report

# Lets Postgres identify Report Service
ALLURE_REPORT_SERVICE_NAME=allure-report-service

# Report Context Path. Please DO NOT CHANGE
ALLURE_REPORT_CONTEXT_PATH=/rs

# Report port, DO NOT CHANGE
ALLURE_REPORT_PORT=8081

# Postgres Host

# Compose
ALLURE_REPORT_DB_HOST=report-db
# Hostname
ALLURE_REPORT_DB_HOST=pg.example.com
# IP
ALLURE_REPORT_DB_HOST="192.168.10.64"

# Report Database Name
ALLURE_REPORT_DB_NAME=report

# Report Database user/role
ALLURE_REPORT_DB_USERNAME=report

# Report Database pass
ALLURE_REPORT_DB_PASS=<IDontReadDocs>

# UAA Database Port
ALLURE_REPORT_DB_PORT=5432

## RabbitMQ

# Compose
ALLURE_RABBIT_HOST=rabbitmq

# Hostname
ALLURE_RABBIT_HOST=mq.example.com

# IP
ALLURE_RABBIT_HOST="192.168.10.67"

# RabbitMQ port
ALLURE_RABBIT_PORT=5672

# RabbitMQ User
ALLURE_RABBIT_USER=allure

# RabbitMQ Pass
ALLURE_RABBIT_PASS=wNaxbX7wEhqA6ZDQ

# S3

# Compose Local, minio-local is a service name
ALLURE_S3_URL=http://minio-local:9000

# Hostname
ALLURE_S3_URL=https://s3.example.com

# IP
ALLURE_S3_URL=https://192.168.10.67:9000

# S3 Bucket
ALLURE_S3_BUCKET=allure-testops

# S3 Region
ALLURE_S3_REGION=qameta-0

# S3 AccessKey / Username in Minio
ALLURE_S3_ACCESS_KEY=<IDontReadDocs>

# S3 SecretKey / Pass in Minio
ALLURE_S3_SECRET_KEY=<IDontReadDocs>

# This parameter tells allure to use Pathstyle
# e.g. ALLURE_S3_PATHSTYLE=true https://s3.example.com/<bucket-name>
# e.g. ALLURE_S3_PATHSTYLE=false https://<bucket-name>.s3.example.com
ALLURE_S3_PATHSTYLE=true

```