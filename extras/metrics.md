# Metrics

## Prometheus

Create ``` mkdir -p /configs/prometheus/``` directory first

```yaml
  prometheus:
    restart: always
    image: prom/prometheus
    container_name: prometheus
    volumes:
      - ./configs/prometheus/:/etc/prometheus/
      - prometheus:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - allure-net
    ports:
      - "9090:9090"

  volumes:
    prometheus:
```

Copy and edit prometheus config to ```./configs/prometheus/prometheus.yml```

```yaml
---
global:
  scrape_interval: 15s
  scrape_timeout: 15s
  external_labels:
    monitor: 'allure-testops'
rule_files:
  - 'alert.rules'

scrape_configs:
  - job_name: 'gateway'
    scrape_interval: 5s
    metrics_path: /management/prometheus
    static_configs:
      - targets:
          - 'allure-gateway:8080'
  - job_name: 'uaa'
    scrape_interval: 5s
    metrics_path: /uaa/management/prometheus
    static_configs:
      - targets:
          - 'allure-uaa:8082'
  - job_name: 'report'
    scrape_interval: 5s
    metrics_path: /rs/management/prometheus
    static_configs:
      - targets:
          - 'allure-report:8081'
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets:
          - 'localhost:9090'
  - job_name: 'cadvisor'
    scrape_interval: 5s
    static_configs:
      - targets:
          - 'cadvisor:8080'
  - job_name: 'node-exporter'
    scrape_interval: 5s
    static_configs:
      - targets:
          - 'node-exporter:9100'
  - job_name: 'pg-db-exporter'
    scrape_interval: 5s
    static_configs:
      - targets:
          - 'uaa-pg-exporter:9187'
          - 'report-pg-exporter:9187'
  - job_name: 'minio-exporter'
    scrape_interval: 5s
    metrics_path: /minio/v2/metrics/node
    scheme: http
    static_configs:
      - targets:
          - 'minio-local:9000'
  - job_name: 'rabbitmq-exporter'
    scrape_interval: 5s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
        - 'rabbitmq-exporter:9419'
```

# Exporters

## UAA Database Exporter

```yaml
  uaa-pg-exporter:
    image: quay.io/prometheuscommunity/postgres-exporter
    container_name: uaa-pg-exporter
    restart: always
    environment:
      DATA_SOURCE_NAME: "postgresql://${ALLURE_UAA_DB_USERNAME}:${ALLURE_UAA_DB_PASS}@${ALLURE_UAA_DB_HOST}:${ALLURE_UAA_DB_PORT}/${ALLURE_UAA_DB_NAME}?sslmode=disable"
    networks:
      - allure-net
```

## Report Database Exporter

```yaml
  report-pg-exporter:
    image: quay.io/prometheuscommunity/postgres-exporter
    container_name: report-pg-exporter
    restart: always
    environment:
      DATA_SOURCE_NAME: "postgresql://${ALLURE_REPORT_DB_USERNAME}:${ALLURE_REPORT_DB_PASS}@${ALLURE_REPORT_DB_HOST}:${ALLURE_REPORT_DB_PORT}/${ALLURE_REPORT_DB_NAME}?sslmode=disable"
    networks:
      - allure-net
```

## RabbitMQ Exporter

```yaml
  rabbitmq-exporter:
    image: kbudde/rabbitmq-exporter
    container_name: rabbitmq-exporter
    restart: always
    networks:
      - allure-net
    environment:
      RABBIT_URL: http://${ALLURE_RABBIT_HOST}:15672
      RABBIT_USER: ${ALLURE_RABBIT_USER}
      RABBIT_PASSWORD: ${ALLURE_RABBIT_PASS}
```

## Node Exporter

```yaml
  node-exporter:
    image: prom/node-exporter
    container_name: node-exporter
    privileged: true
    restart: always
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - --collector.filesystem.ignored-mount-points
      - "^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)"
    networks:
      - allure-net
```

## Cadvisor

```yaml
  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    container_name: cadvisor
    privileged: true
    restart: always
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - allure-net
```

# Grafana

## Grafana Service

Create config directory first ```mkdir -p ./configs/grafana/provisioning/```

```yaml
  grafana:
    image: grafana/grafana
    container_name: grafana
    restart: always
    user: "472"
    depends_on:
      - prometheus
    ports:
      - "3000:3000"
    volumes:
      - ./configs/grafana/provisioning:/etc/grafana/provisioning
      - grafana:/var/lib/grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_USERS_ALLOW_SIGN_UP: false
    networks:
      - allure-net
  volumes:
    grafana:
```

### Grafana Config

```./configs/grafana/provisioning/default.yaml```

```yaml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    options:
      path: /etc/grafana/provisioning
```

```./configs/grafana/provisioning/datasources/default.yaml```

```yaml
# # config file version
apiVersion: 1

# # list of datasources that should be deleted from the database
#deleteDatasources:
#   - name: Graphite
#     orgId: 1

# # list of datasources to insert/update depending
# # on what's available in the database
datasources:
#   # <string, required> name of the datasource. Required
 - name: Prometheus
   # <string, required> datasource type. Required
   type: prometheus
#   # <string, required> access mode. direct or proxy. Required
   access: proxy
#   # <int> org id. will default to orgId 1 if not specified
#   orgId: 1
#   # <string> url
   url: http://prometheus:9090
#   # <string> database password, if used
#   password:
#   # <string> database user, if used
#   user:
#   # <string> database name, if used
#   database:
#   # <bool> enable/disable basic auth
#   basicAuth:
#   # <string> basic auth username
#   basicAuthUser:
#   # <string> basic auth password
#   basicAuthPassword:
#   # <bool> enable/disable with credentials headers
#   withCredentials:
#   # <bool> mark as default datasource. Max one per org
   isDefault: true
#   # <map> fields that will be converted to json and stored in json_data
#   jsonData:
#      graphiteVersion: "1.1"
#      tlsAuth: true
#      tlsAuthWithCACert: true
#      httpHeaderName1: "Authorization"
#   # <string> json object of data that will be encrypted.
#   secureJsonData:
#     tlsCACert: "..."
#     tlsClientCert: "..."
#     tlsClientKey: "..."
#     # <openshift\kubernetes token example>
#     httpHeaderValue1: "Bearer xf5yhfkpsnmgo"
#   version: 1
#   # <bool> allow users to edit datasources from the UI.
   editable: true
```

Open Grafana UI (http/s://your_hostname:3000)
LogIn admin/admin
Press Import Dashboard
Enter ID ```16841```
Complete Import