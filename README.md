# Docker Compose Official Deployment

### Step for Running Allure Testops
## IMPORTANT: make sure you have docker-compose version > 2.x
How to install Docker Compose v2 (this is not about docker-compose file version like 3.9)
```bash
apt update && apt install docker.io
export DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```
To check you've done everything fine
```bash
docker compose version
```
1. Create .env file (You can find example in directory)
```shell
cp env-example .env
```
then EDIT YOUR values
2. Run:
```shell
export COMPOSE_PROFILES=default,postgres,redis,rabbit,minio-local
docker-compose up -d
```
OR
```shell
docker-compose \
    --profile default \
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

#### If you want to use built in postgres. Don't use it if you have external postgres.
1. postgres

#### If you want to use built in redis. In most cases you don't need to use external because its used only for keeping sessions
2. redis

#### If you want to use built in rabbit.
3. rabbit

#### If you want to use built in minio (Default FS for Allure Artifacts)
4. minio-local

#### If you want to use external S3 storage like AWS S3, Azure S3, Google S3 etc... use this profile. Don't forget
#### to edit .env variables
5. minio-proxy

#### Ldap auth. Doesn't work WITH default profile at the SAME TIME
6. ldap
#### Metrics. Runs with Prometheus Grafana and exporters
7. metrics

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

3. Sometimes database lock in not removed by allure-report. Plz delete one
