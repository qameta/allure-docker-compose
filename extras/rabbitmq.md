# RabbitMQ

IT IS NOT RECOMMENDED TO USE RABBITMQ IN DOCKER-COMPOSE ON PRODUCTION DEPLOYMENT. QAMETA SOFTWARE IS NOT RESPONSIBLE FOR DATA LOSS IN THIS CASE

## RabbitMQ Service

```yaml
---
rabbitmq:
  restart: always
  image: bitnami/rabbitmq
  container_name: rabbitmq
  networks:
    - allure-net
  volumes:
    - rabbitmq-volume:/bitnami
  environment:
    RABBITMQ_USERNAME: ${ALLURE_RABBIT_USER}
    RABBITMQ_PASSWORD: ${ALLURE_RABBIT_PASS}
    RABBITMQ_NODE_PORT_NUMBER: ${ALLURE_RABBIT_PORT}
    RABBITMQ_ERL_COOKIE: ${RABBIT_ERLANG_COOKIE}

volumes:
  rabbitmq-volume:
```

### .env

```dotenv
ALLURE_RABBIT_HOST=rabbitmq
ALLURE_RABBIT_PORT=5672
ALLURE_RABBIT_USER=allure
ALLURE_RABBIT_PASS=<password>
```
