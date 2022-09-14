# RabbitMQ

IT IS NOT RECOMMENDED TO USE RABBITMQ IN DOCKER-COMPOSE ON PRODUCTION DEPLOYMENT. QAMETA SOFTWARE IS NOT RESPONSIBLE FOR DATA LOSS IN THIS CASE

## RabbitMQ Service

```yaml
---
rabbitmq:
  restart: always
  image: rabbitmq:3.9-management
  container_name: rabbitmq
  networks:
    - allure-net
  volumes:
    - rabbitmq-volume:/var/lib/rabbitmq
  environment:
    RABBITMQ_DEFAULT_USER: ${ALLURE_RABBIT_USER}
    RABBITMQ_DEFAULT_PASS: ${ALLURE_RABBIT_PASS}

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
