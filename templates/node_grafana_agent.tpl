%{ if prometheus_enabled }
metrics:
  wal_directory: /var/lib/agent/wal
  global:
    external_labels:
      cluster_name: ${cluster_name}
    scrape_interval: ${prometheus_scrape_interval}
    remote_write:
      - url: ${prometheus_url}
        basic_auth:
          username: ${prometheus_user}
          password: ${prometheus_pass}
        write_relabel_configs:
          - source_labels:
              - "__name__"
            regex: "${prometheus_metrics_filter}"
            action: "keep"
          - regex: "${prometheus_labels_filter}"
            action: "labelkeep"
        queue_config:
          max_samples_per_send: 1000
          max_shards: 200
          capacity: 2500
integrations:
  node_exporter:
    enabled: true
    rootfs_path: /host/root
    sysfs_path: /host/sys
    procfs_path: /host/proc
%{ endif ~}

%{ if loki_enabled ~}
logs:
  configs:
    - name: default
      clients:
      - url: ${loki_url}
        basic_auth:
          username: ${loki_user}
          password: ${loki_pass}
        external_labels:
          cluster: ${cluster_name}
        tenant_id: default
      positions:
        filename: /tmp/positions.yaml
      target_config:
        sync_period: 10s
      scrape_configs:
        - job_name: pod-logs
          kubernetes_sd_configs:
            - role: pod
          pipeline_stages:
            - cri: {}
            - json:
                expressions:
                  output: log
                  stream: stream
                  timestamp: time
                drop_malformed: false
            - json:
                expressions:
                  level: level
                  scope: scope
                  country_code: country_code
                drop_malformed: false
            - labels:
                stream:
                level:
                scope:
                country_code:
            - labelallow:
                - cluster
                - namespace
                - budgetbakers_com_app
                - app_kubernetes_io_instance
                - container
                - job_name
                - stream
                - level
                - scope
                - retention
                - country_code
            - match:
                selector: '{scope="audit"}'
                stages:
                  - tenant:
                      value: "audit"
            - match:
                selector: '{scope="security"}'
                stages:
                  - tenant:
                      value: "security"
          relabel_configs:
            - source_labels:
                - __meta_kubernetes_pod_node_name
              target_label: __host__
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            - action: replace
              replacement: $1
              separator: /
              source_labels:
                - __meta_kubernetes_namespace
                - __meta_kubernetes_pod_name
              target_label: job
            - action: replace
              source_labels:
                - __meta_kubernetes_namespace
              target_label: namespace
            - action: replace
              source_labels:
                - __meta_kubernetes_pod_name
              target_label: pod
            - action: replace
              source_labels:
                - __meta_kubernetes_pod_container_name
              target_label: container
            - replacement: /var/log/pods/*$1/*.log
              separator: /
              source_labels:
                - __meta_kubernetes_pod_uid
                - __meta_kubernetes_pod_container_name
              target_label: __path__
%{ endif ~}
