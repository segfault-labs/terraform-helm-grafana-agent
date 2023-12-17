%{ if prometheus_enabled ~}
metrics:
  wal_directory: /tmp/wal
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
  configs:
  - name: integrations
    scrape_configs:
    - job_name: integrations/kubernetes/cadvisor
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
        - role: node
      relabel_configs:
        - replacement: kubernetes.default.svc:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
          source_labels:
            - __meta_kubernetes_node_name
          target_label: __metrics_path__
      scheme: https
      tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: false
          server_name: kubernetes
    - job_name: integrations/kubernetes/kubelet
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
        - role: node
      relabel_configs:
        - replacement: kubernetes.default.svc:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$1/proxy/metrics
          source_labels:
            - __meta_kubernetes_node_name
          target_label: __metrics_path__
      scheme: https
      tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: false
          server_name: kubernetes
    - job_name: integrations/kubernetes/service-endpoints
      kubernetes_sd_configs:
        - role: endpoints
      relabel_configs:
        - source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_scrape
          action: keep
          regex: true
        - source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_scheme
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_path
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels:
          - __address__
          - __meta_kubernetes_service_annotation_prometheus_io_port
          action: replace
          target_label: __address__
          regex: (.+)(?::\d+);(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels:
          - __meta_kubernetes_namespace
          action: replace
          target_label: kubernetes_namespace
        - source_labels:
          - __meta_kubernetes_service_name
          action: replace
          target_label: kubernetes_name
    - job_name: integrations/kubernetes/pods
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: true
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        - source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scrape
          action: keep
          regex: 'true'
        - source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_path
          action: replace
          target_label: __metrics_path__
          regex: "(.+)"
        - source_labels:
          - __address__
          - __meta_kubernetes_pod_annotation_prometheus_io_port
          action: replace
          regex: "([^:]+)(?::[0-9]+)?;([0-9]+)"
          replacement: "$1:$2"
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels:
          - __meta_kubernetes_namespace
          action: replace
          target_label: kubernetes_namespace
        - source_labels:
          - __meta_kubernetes_pod_name
          action: replace
          target_label: kubernetes_pod_name
    - job_name: integrations/kubernetes/autoscaler
      scrape_interval: 3s
      scrape_timeout: 3s
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        # Scrape only the the targets matching the following metadata
        - source_labels:
          - __meta_kubernetes_namespace
          - __meta_kubernetes_pod_label_app
          - __meta_kubernetes_pod_container_port_name
          action: keep
          regex: knative-serving;autoscaler;metrics
        # Rename metadata labels to be reader friendly
        - source_labels:
          - __meta_kubernetes_namespace
          target_label: namespace
        - source_labels:
          - __meta_kubernetes_pod_name
          target_label: pod
        - source_labels:
          - __meta_kubernetes_service_name
          target_label: service
    - job_name: integrations/kubernetes/activator
      scrape_interval: 3s
      scrape_timeout: 3s
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      # Scrape only the the targets matching the following metadata
      - source_labels:
        - __meta_kubernetes_namespace
        - __meta_kubernetes_pod_label_app
        - __meta_kubernetes_pod_container_port_name
        action: keep
        regex: knative-serving;activator;metrics-port
      # Rename metadata labels to be reader friendly
      - source_labels:
        - __meta_kubernetes_namespace
        target_label: namespace
      - source_labels:
        - __meta_kubernetes_pod_name
        target_label: pod
      - source_labels:
        - __meta_kubernetes_service_name
        target_label: service
%{ endif ~}

%{ if loki_enabled ~}
logs:
  configs:
    - name: integrations
      clients:
      - url: ${loki_url}
        basic_auth:
          username: ${loki_user}
          password: ${loki_pass}
        external_labels:
          cluster: ${cluster_name}
          job: integrations/kubernetes/eventhandler
        tenant_id: default
      positions:
        filename: /tmp/positions.yaml
      target_config:
        sync_period: 10s
%{ endif ~}

integrations:
  agent:
%{ if length(blackbox_targets) != 0 ~}
  blackbox:
    enabled: true
    blackbox_targets:
%{ for k, v in blackbox_targets ~}
      - name: ${v.name}
        address: ${v.url}
        module: http_2xx
%{ endfor ~}
    relabel_configs:
      - source_labels: [__param_module]
        target_label: module
      - source_labels: [__param_target]
        target_label: instance
    blackbox_config:
      modules:
        http_2xx:
          prober: http
          timeout: 5s
          http:
            valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
            valid_status_codes: []
            method: GET
            no_follow_redirects: false
            fail_if_ssl: false
            fail_if_not_ssl: false
            tls_config:
              insecure_skip_verify: false
            preferred_ip_protocol: "ip4" # defaults to "ip6"
            ip_protocol_fallback: false  # no fallback to "ip6"
%{ endif ~}
%{ loki_enabled = true ~}
  eventhandler:
    cache_path: /var/lib/agent/eventhandler.cache
    logs_instance: integrations
%{ endif ~}
