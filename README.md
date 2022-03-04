# Docker Compose Official Deployment

## SSL Usage

### Step for all ssl deployments

1. run ```chmod +x scripts/dhparam-gen.sh```
2. run ```./scripts/dhparam-gen.sh```

### Step for own certificates
1. copy your Certificate to ```./certs/your-certificate.pem```
2. copy your Private key to ```./certs/your-key.pem```
3. edit ENV variable ```ALLURE_CERTIFICATE``` to actual path in ```.env``` file
4. edit ENV variable ```ALLURE_KEY``` to actual path in ```.env``` file

### Step for Running Allure Testops
## IMPORTANT: make sure you have docker-compose version > 2.x
1. Create .env file (You can find example in directory)
```shell
cp env-example .env
```
then EDIT YOUR values
2. Run:
```shell
export COMPOSE_PROFILES=default,insecure-nginx,postgres,redis,rabbit,minio-local
docker-compose up -d
```
OR
```shell
docker-compose \
    --profile default \
    --profile insecure-nginx \
    --profile postgres \
    --profile redis \
    --profile rabbit \
    --profile minio-local \
    up -d
```

## Profiles
As sometimes we don't need internal dependencies like postgres, redis, rabbit we use profiles to exclude or
include required module

Profiles:
#### Default App Auth. Do NOT use default if you use ldap profile
0. default
#### If you want to run allure on port 80
1. insecure-nginx 

#### If you want to run allure on port 80 & 443
2. secure-nginx

#### If you want to obtain SSL certs by certbot
3. certbot

#### If you want to use built in postgres. Don't use it if you have external postgres.
4. postgres

#### If you want to use built in redis. In most cases you don't need to use external because its used only for keeping sessions
5. redis

#### If you want to use built in rabbit.
6. rabbit

#### If you want to use built in minio (Default FS for Allure Artifacts)
7. minio-local

#### If you want to use external S3 storage like AWS S3, Azure S3, Google S3 etc... use this profile. Don't forget
#### to edit .env variables
8. minio-proxy

#### Ldap auth. Doesn't work WITH default profile at the SAME TIME
9. ldap
#### Metrics. Runs with Prometheus Grafana and exporters
10. metrics

## Metrics
Make sure you have ./configs/prometheus/prometheus.yml tuned for minio scraping location

## Troubleshooting
Docker Compose is Non Production kind of deployments, so using it means you assume all risks and take them.
Here some cases you can deal with problems:

1. Something not working.
Run ```docker-compose logs -f consul```
#### You may see some healthchecks may not pass. Restart unhealthy service with:
```docker-compose restart <unhealthy_service>```

2. You cannot add healthchecks in docker-compose.yml because images with allure service doesn't contain curl
and docker-compose unlike k8s cannot perform native checks

3. You ran docker-compose but you see nothing in browser. This means you have not enough privileges to run on
port 80 || 443. Use sudo then.

4. Sometimes database lock in not removed by allure-report. Plz delete one
