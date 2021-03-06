prometheus:
  server:
    enabled: true
    dir:
      config: /srv/volumes/prometheus/server
      config_in_container: /srv/prometheus
      data: /srv/volumes/local/prometheus/server
    bind:
      port: 9090
      address: 0.0.0.0
    external_port: 15010
    target:
      dns:
        enabled: true
        endpoint:
          - name: 'pushgateway'
            domain:
            - 'tasks.prometheus_pushgateway'
            type: A
            port: 9091
          - name: 'prometheus'
            domain:
            - 'tasks.prometheus_server'
            type: A
            port: 9090
      kubernetes:
        enabled: true
        api_ip: 127.0.0.1
        ssl_dir: /opt/prometheus/config
        cert_name: prometheus-server.crt
        key_name: prometheus-server.key
      etcd:
        endpoint:
          scheme: https
          ssl_dir: /opt/prometheus/config
          cert_name: prometheus-server.crt
          key_name: prometheus-server.key
          member:
            - host: 10.0.175.101
              port: 4001
            - host: 10.0.175.102
              port: 4001
            - host: 10.0.175.103
              port: 4001
    recording:
      instance:fd_utilization:
        query: >-
          process_open_fds / process_max_fds
    alert:
      PrometheusTargetDown:
        if: 'up != 1'
        labels:
          severity: down
        annotations:
          summary: 'Prometheus target down'
    storage:
      local:
        retention: "360h"
    alertmanager:
      notification_queue_capacity: 10000
    config:
      global:
        scrape_interval: "15s"
        scrape_timeout: "15s"
        evaluation_interval: "1m"
        external_labels:
          region: 'region1'
      remote_write:
        remote_storage_adapter:
          enabled: true
          url: "http://127.0.0.1:9201/write"
      alertmanager:
        docker_swarm_alertmanager:
          enabled: true
          dns_sd_configs:
            domain:
              - tasks.monitoring_alertmanager
            type: A
            port: 9093
docker:
  host:
    enabled: true
    experimental: true
    insecure_registries:
      - 127.0.0.1
    log:
      engine: json-file
      size: 50m
