# DATABASES

IT IS NOT RECOMMENDED TO USE DATABASE IN DOCKER-COMPOSE ON PRODUCTION DEPLOYMENT. QAMETA SOFTWARE IS NOT RESPONSIBLE FOR DATA LOSS IN THIS CASE

## UAA Database Service
```yaml
---
uaa-db:
  restart: always
  image: postgres:14
  container_name: uaa-db
  networks:
    - allure-net
  volumes:
    - uaa-db-volume:/var/lib/postgresql/data
  environment:
    TZ: ${TZ}
    POSTGRES_DB: ${ALLURE_UAA_DB_NAME}
    POSTGRES_USER: ${ALLURE_UAA_DB_USERNAME}
    POSTGRES_PASSWORD: ${ALLURE_UAA_DB_PASS}

volumes:
  uaa-db-volume:
```
### .env

```dotenv
# Should be equal to docker-compose service, container_name
ALLURE_UAA_DB_HOST=uaa-db
ALLURE_UAA_DB_NAME=uaa
ALLURE_UAA_DB_USERNAME=uaa
ALLURE_UAA_DB_PASS=<your_password>
ALLURE_UAA_DB_PORT=5432
```
## Report Database Service

```yaml
report-db:
  restart: always
  image: postgres:14
  container_name: report-db
  networks:
    - allure-net
  volumes:
    - report-db-volume:/var/lib/postgresql/data
  environment:
    TZ: ${TZ}
    POSTGRES_DB: ${ALLURE_REPORT_DB_NAME}
    POSTGRES_USER: ${ALLURE_REPORT_DB_USERNAME}
    POSTGRES_PASSWORD: ${ALLURE_REPORT_DB_PASS}

volumes:
  report-db-volume:
```
### .env

```dotenv
# Should be equal to docker-compose service, container_name
ALLURE_REPORT_DB_HOST=report-db
ALLURE_REPORT_DB_NAME=report
ALLURE_REPORT_DB_USERNAME=report
ALLURE_REPORT_DB_PASS=<your_password>
ALLURE_REPORT_DB_PORT=5432
```
