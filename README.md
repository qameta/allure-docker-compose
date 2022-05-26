# Official template for Deployment using Docker Compose

## Disclaimer

Deployment via docker compose is not suitable for production deployment, so using it means you assume all risks and accept them.

## IMPORTANT NOTICE

**IMPORTANT: make sure you have docker-compose version > 2.x**

### Installing docker compose v.2

Please check [official Docker's installation guide.](https://docs.docker.com/compose/install/)

Basically you need to do the following (current actual release could be different, in the example below we use, so please refer to the official doc mentioned above):

```bash
apt update && apt install docker.io
export DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```

To check you've done everything correctly execute the command:

```bash
docker compose version
```

IMPORTANT: **docker compose** should be used witрout dashes

## Step for Running Allure TestOps

1. Create .env file by copying our template (env-example)

```shell
cp env-example .env
```

2. Edit the values specific for your deployment
3. Define the list of profiles to be used for the deployment and the start (see description in Profiles section).
4. Add the list of profiles on top of `.env`

    ```shell
    export COMPOSE_PROFILES=default,postgres,redis,rabbit,minio-local
    ```

5. Run the docker compose deployment by executing the command

```shell
docker-compose up -d
```

## Profiles

The deployment consists of several services needed to successfully run the business logic.

Sometimes auxiliary services we need are present in your infrastructure and we could reuse them. In this case similar service included into the configuration is not needed and we need exclude appropriate profile from using.

Profiles need to be included in the list of the used profiles only in case the required system is absent in your infrastructure.

A profile defines a service which needs to be included in the configuration to start with Allure TestOps.

Some of profiles are incompatible with each other, so be careful with the configuration.

### Available profiles

0. default
   - must be disabled if `ldap` profile is used 
1. postgres
   - Enable this profile if you want to use Postgres database in a container started alongside with Allure TestOps.
   - Don't enable this profile it if you have dedicated PostgreSQL server.
2. redis
   - Enable this profile if you want to use Redis in a container started alongside with Allure TestOps. In vast majority of cases, you don't need to have dedicated Redis server as Redis is used to store sessions information only.
3. rabbit
   - Enable this profile if you want to use RabbitMQ in a container started alongside with Allure TestOps.
   - Don't enable, if there is a dedicated RabbitMQ server in the infrastructure and you are allowed to use it with Allure TestOps.
4. minio-local
   - Enable this profile if you want to use min.io (S3 solution to use tests' artifacts) in a container started alongside with Allure TestOps.
   - Don't enable if you have dedicated S3 in your network or you are buying S3 services from a cloud provider (AWS, GCS).
   - If you have dedicated services, then you need additional configuration for the S3 integration (`.env`).
5. minio-proxy
   -  Enable this profile if you want to use min.io as caching proxy before storing files in your S3 solution. It allows you to save some traffic and avoid unnecessary operations with S3.
6. ldap
   - Enable if you are going to integrate Allure TestOps with your LDAP (AD) and use LDAP authentication. 
   - This profile must not be enables simultaneously with the `default` profile.
7. metrics
   - Enable this profile is you are going to collect metrics from Allure TestOps.  
   - This works with Prometheus, Grafana and exporters.
   - Make sure you have `./configs/prometheus/prometheus.yml` tuned for minio scraping location.

## Troubleshooting

To understand what's wrong with your services, you need to collect log form the running (even if it has failed)



Here some cases you can deal with problems:

1. Something not working.
Run ```docker-compose logs -f consul```
#### You may see some healthchecks may not pass. Restart unhealthy service with:
```docker-compose restart <unhealthy_service>```

2. You cannot add healthchecks in docker-compose.yml because images with allure service doesn't contain curl
and docker-compose unlike k8s cannot perform native checks

3. Sometimes database lock in not removed by allure-report. Plz delete one
