# Minio

IT IS NOT RECOMMENDED TO USE MINIO IN DOCKER-COMPOSE ON PRODUCTION DEPLOYMENT. QAMETA SOFTWARE IS NOT RESPONSIBLE FOR DATA LOSS IN THIS CASE

## Minio Service

```yaml
minio-local:
  restart: always
  image: bitnami/minio:2022
  container_name: minio-local
  networks:
    - allure-net
  volumes:
    - minio-volume:/data
  environment:
    MINIO_ROOT_USER: ${ALLURE_S3_ACCESS_KEY}
    MINIO_ROOT_PASSWORD: ${ALLURE_S3_SECRET_KEY}
    MINIO_PROMETHEUS_AUTH_TYPE: 'public'
  ports:
    - "9000:9000"

volumes:
  minio-volume:
```

### .env

```dotenv
# minio-local comes from container_name in service description above
ALLURE_S3_URL=http://minio-local:9000
ALLURE_S3_PROVIDER=s3
ALLURE_S3_BUCKET=allure-testops
ALLURE_S3_REGION=qameta-0
ALLURE_S3_ACCESS_KEY=<username>
ALLURE_S3_SECRET_KEY=<password>
ALLURE_S3_PATHSTYLE=true
```
## Minio Provisioning Job
Do not worry when you see dead container after docker compose ps. It's job and it should die after completion.
This job creates bucket in minio, so TestOps can store files in it. ENVs are used from minio service 

```yaml
minio-provisioning:
  restart: "no"
  image: minio/mc
  container_name: minio-provisioning
  depends_on:
    - minio-local
  networks:
    - allure-net
  entrypoint: "/bin/sh -c"
  command: >
    "mc config host add minio ${ALLURE_S3_URL} ${ALLURE_S3_ACCESS_KEY} ${ALLURE_S3_SECRET_KEY} --api S3v4 &&
    mc mb minio/${ALLURE_S3_BUCKET} --ignore-existing --region ${ALLURE_S3_REGION} &&
    mc admin info minio"
```

## Minio Proxy Service
Minio Proxy is designed to cache S3 traffic between Allure TestOps and External S3 Provider (NOT MINIO)

```yaml
  minio-proxy:
    restart: always
    image: quay.io/minio/minio
    container_name: minio-proxy
    networks:
      - allure-net
    volumes:
      - minio-cache:/minio-cache
    environment:
      MINIO_ROOT_USER: ${ALLURE_S3_ACCESS_KEY}
      MINIO_ROOT_PASSWORD: ${ALLURE_S3_SECRET_KEY}
      MINIO_PROMETHEUS_AUTH_TYPE: 'public'
      MINIO_CACHE: "on"
      MINIO_CACHE_DRIVES: /minio-cache
      MINIO_CACHE_QUOTA: 70
      MINIO_CACHE_AFTER: 3
      MINIO_CACHE_WATERMARK_LOW: 30
      MINIO_CACHE_WATERMARK_HIGH: 75
    entrypoint: "/bin/sh -c"
    command: >
      "minio gateway ${ALLURE_S3_PROVIDER} ${ALLURE_S3_URL}"
```

### .env

```dotenv
ALLURE_S3_PROVIDER=s3
# Tells Allure TestOps to connect Proxy
ALLURE_S3_URL=http://minio-proxy:9000
ALLURE_S3_URL=https://<your_S3_provider_API_endpoint_here>
ALLURE_S3_BUCKET=allure-testops
ALLURE_S3_REGION=fra1
ALLURE_S3_ACCESS_KEY=<your_access_key>
ALLURE_S3_SECRET_KEY=<your_secret_key>
ALLURE_S3_PATHSTYLE=true
```

## Minio Proxy Provisioning Job
Makes Sure Bucket Exists
```yaml
  minio-proxy-provisioning:
    restart: "no"
    image: minio/mc
    container_name: minio-provisioning
    depends_on:
      - minio-proxy
    networks:
      - allure-net
    entrypoint: "/bin/sh -c"
    command: >
      "mc alias set ${ALLURE_S3_PROVIDER} ${ALLURE_S3_URL} ${ALLURE_S3_ACCESS_KEY} ${ALLURE_S3_SECRET_KEY} --api S3v4 &&
       mc mb --ignore-existing ${ALLURE_S3_PROVIDER}/${ALLURE_S3_BUCKET} &&
       mc admin info ${ALLURE_S3_PROVIDER}"
```

Envs are reused from Minio Proxy

## Minio Migration Job

This job is handy if you want to migrate from Local Minio to External Minio or Other
S3 Storage. To perform that you need:

1. Disable LoadBalancer to stop TestOps receiving new data.
2. Wait until no jobs left in RabbitMQ (http/https)://<your_rabbit_host>:15672
3. Add service described below (minio-migrate) and add .env props
4. ```docker compose down```
5. ```docker compose up -d```
6. Wait until minio-migrate finishes (```docker compose ps```). It may take a while

```yaml
minio-migrate:
  restart: "no"
  image: minio/mc
  container_name: minio-migrate
  depends_on:
    - minio
  networks:
    - allure-net
  entrypoint: "/bin/sh -c"
  command: >
    "mc config host add minio-old ${ALLURE_S3_URL} ${ALLURE_S3_ACCESS_KEY} ${ALLURE_S3_SECRET_KEY} --api S3v4 &&
     mc config host add s3-new ${S3_URL_NEW} ${ALLURE_S3_ACCESS_KEY_NEW} ${ALLURE_S3_SECRET_KEY_NEW} --api S3v4 &&
     mc cp -r minio-old/${ALLURE_S3_BUCKET}/v2 s3-new/${ALLURE_S3_BUCKET_NEW}/"
```
### .env

```dotenv
S3_URL_NEW=http(s)://<new_host>:<port>
ALLURE_S3_ACCESS_KEY_NEW=<ACCESS_KEY_OF_NEW_S3>
ALLURE_S3_SECRET_KEY_NEW=<SECRET_KEY_OF_NEW_S3>
ALLURE_S3_BUCKET_NEW=<bucket_name>
```

## FS to Minio Migration Job

This job is handy to migrate from plain file system to S3

To perform that you need:
1. Disable LoadBalancer to stop TestOps receiving new data.
2. Wait until no jobs left in RabbitMQ (http/https)://<your_rabbit_host>:15672
3. Add service described below (fs-migrate) and add .env props
4. ```docker compose down```
5. ```docker compose up -d```
6. Wait until fs-migrate finishes (```docker compose ps```). It may take a while

```yaml
fs-migrate:
  restart: "no"
  image: minio/mc
  container_name: minio-fs-migrate
  networks:
    - allure-net
  entrypoint: "/bin/sh -c"
  volumes:
    ${REPORT_VOLUME}:/data
  command: >
    mc config host add s3 ${ALLURE_S3_URL} ${ALLURE_S3_ACCESS_KEY} ${ALLURE_S3_SECRET_KEY} --api S3v4 &&
    mc mb s3/${ALLURE_S3_BUCKET} --ignore-existing --region ${ALLURE_S3_REGION} &&
    mc cp -r /data/v2 s3/${ALLURE_S3_BUCKET}/
```

### .env

```dotenv
ALLURE_S3_URL=http(s)://<new_host>:<port>
ALLURE_S3_ACCESS_KEY=<username>
ALLURE_S3_SECRET_KEY=<password>
ALLURE_S3_BUCKET=<bucket_name>
ALLURE_S3_REGION=<region>
```
