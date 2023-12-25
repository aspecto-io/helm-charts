{{- define "collector.reciver.protocol.otlp" -}}
{{- $service := .service }}
{{- $localListenerIp := .localListenerIp }}
{{- range .protocols }}
{{- if and (eq .name $service) (.enabled )}}
{{- if eq .name "jaeger-http"}}thrift_http:{{- else if eq .name "jaeger-grpc" }}grpc:{{- else }}{{ .name }}:{{- end }}
  endpoint: {{ $localListenerIp }}:{{ .internalPort }}
    {{- if eq .name "grpc" }}
  max_recv_msg_size_mib: {{ .maxReceivedMessageSizeMiB }}
    {{- end }}
{{- end }}
    {{- end }}
{{- end }}

{{- define "collector.reciver.protocol.metrics" -}}{{ $service := .service }}{{ $localListenerIp := .localListenerIp }}
{{- range .protocols }}
    {{- if and (eq .name $service) (.enabled )}}
  prometheus:
    config:
      scrape_configs:
        - job_name: "otelcol-sampling"
          scrape_interval: 10s
          static_configs:
            - targets: ["{{ $localListenerIp }}:{{ .internalPort }}"]
    {{- end }}
{{- end }}
{{- end }}


{{- define "collector.configMap.processors.resource" -}}
{{ printf "" }}
  attributes:
    - key: aspecto.customer.prem
      value: true
      action: insert
    - key: aspecto.token
      value: ${token}
      action: insert
    - key: deployment.environment
      value: {{ .environment }}
      action: insert
{{- end }}


{{- define "collector.configMap.services.telemetry" }}
{{ $localListenerIp := .localListenerIp }}
{{- range .protocols }}
{{- if and (eq .name "metrics") (.enabled )}}
telemetry:
  metrics:
    address: {{ $localListenerIp }}:{{ .internalPort }}
{{- end }}
{{- end }}
{{- end }}


{{- define "collector.configMap.processors.filter" }}
{{- range .protocols }}
{{- if and (eq .name "metrics") (.enabled )}}
filter:
  metrics:
    include:
      match_type: strict
      metric_names:
        - otelcol_processor_tail_sampling_policy_evaluation_decision
        - otelcol_processor_tail_sampling_count_spans_sampled
{{- end }}
{{- end }}
{{- end }}

{{- define "collector.configMap.exporters.metrics" }}{{ $service := .service}}{{ $endpoint := .endpoint }}{{- range .protocols }}
{{- if and (eq .name $service) (.enabled )}}
otlp/metrics:
  endpoint: {{ $endpoint }}
{{- end }}
{{- end }}
{{- end }}

{{- define "collector.configMap.exporters.sendingQueue" -}}
{{- if .sending_queue }}
  sending_queue:
    enabled: {{ .sending_queue }}
    queue_size: {{ .queue_size }}
    num_consumers: {{ .num_consumers }}
{{- end }}
{{- end }}

{{- define "collector.configMap.exporters.logs" -}}
{{- if .enable }}
  logging:
    verbosity: {{ .logVerbosity }}
{{- end }}
{{- end }}

{{- define "collector.configMap.exporters.kafka" -}}
kafka:
  brokers:
  {{- range .kafka.brokers }}
    - {{ . }}
  {{- end }}
  encoding: {{ .kafka.encoding }}
  auth:
    sasl:
      username: ${KAFKA_USERNAME}
      password: ${KAFKA_PASSWORD}
      mechanism: {{ .kafka.auth.mechanism }}
    tls:
      insecure: false
  producer:
    compression: {{ .kafka.producer.compression }}
    max_message_bytes: {{ .kafka.producer.max_message_bytes }}
    flush_max_messages: {{ .kafka.producer.flush_max_messages }}
  protocol_version: {{ .kafka.protocol_version }}
{{- end }}

{{- define "collector.configMap.extentions" -}}{{ $service := .service }}{{ $localListenerIp := .localListenerIp }}
{{- range .protocols }}
    {{- if and (eq .name $service) (.enabled )}}
    {{ .name }}:
      endpoint: {{ $localListenerIp }}:{{ .internalPort }}
    {{- end }}
{{- end }}
{{- end }}


{{- define "collector.configMap.services.healthCheck" -}}
{{ printf "" }}
  extensions: [health_check]
{{- end }}

{{- define "collector.configMap.services.pipelines.traces" -}}
{{ printf "" }}
    receivers: [otlp]
    processors: [tail_sampling, resource, batch]
    {{- if and (.logs) (.kafka) }}
    exporters: [otlp/traces, kafka, logging]
    {{- else if .kafka }}
    exporters: [otlp/traces, kafka]
    {{- else if .logs }}
    exporters: [otlp/traces, logging]
    {{ else }}
    exporters: [otlp/traces]
    {{- end }}
{{- end }}

{{- define "collector.configMap.services.pipelines.metrics" -}}{{ $service := .service }}{{ $localListenerIp := .localListenerIp }}
{{- range .protocols }}
    {{- if and (eq .name $service) (.enabled )}}
  metrics:
    receivers: [prometheus]
    processors: [filter, resource, batch]
    exporters: [otlp/metrics]
    {{- end }}
{{- end }}
{{- end }}

{{- define "collector.services" -}}
{{ $service := .service -}}
{{- range .protocols }}{{- if and (eq .name $service) (.enabled )}}
    - {{ .name }}
{{- end }}
{{- end }}
{{- end }}

{{- define "get-redis-endpoint" }}
    {{- if eq .Values.redis.config.type "external" -}}
        {{- print .Values.redis.config.endpoint -}}
    {{- else -}}
        {{- printf "%s-%s:%s" .Values.global.name "redis" .Values.redis.specs.port }}
    {{- end -}}
{{- end -}}
