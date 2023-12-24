{{- define "receiver.configMap.reciver.grpc" -}}
{{ printf "" }}
  grpc:
    endpoint: {{ .localListenerIp }}:{{ .internalPort }}
    max_recv_msg_size_mib: {{ .maxReceivedMessageSizeMiB }}
{{- end }}

{{- define "receiver.configMap.reciver.http" -}}
{{ printf "" }}
  http:
    endpoint: {{ .localListenerIp }}:{{ .internalPort }}
{{- end }}

{{- define "receiver.configMap.processors" -}}
{{ printf "" }}
  tail_sampling: $$aspecto:tail_sampling
  resource:
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
  batch:
{{- end }}

{{- define "receiver.configMap.exporters.sendingQueue" -}}
{{ printf "" }}
  sending_queue:
    enabled: {{ .sending_queue }}
    queue_size: {{ .queue_size }}
    num_consumers: {{ .num_consumers }}
{{- end }}

{{- define "receiver.configMap.exporters.logs" -}}
{{ printf "" }}
  logging:
    verbosity: {{ .logVerbosity }}
{{- end }}

{{- define "receiver.configMap.extentions" -}}{{ $service := .service }}{{ $localListenerIp := .localListenerIp }}
{{- range .protocols }}{{- if and (eq .name $service) (.enabled )}}
    {{ .name }}:
      endpoint: {{ $localListenerIp }}:{{ .internalPort }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "reciver.services" -}}{{ $service := .service -}}
{{- range .protocols }}
    {{- if and (eq .name $service) (.enabled )}}
    - {{ .name }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "reciver.services.jaeger" -}}
{{- range .protocols }}
    {{- if and (.enabled ) (or ( eq .name "jaeger-http") ( eq .name "jaeger-grpc")) }}
        {{ $r := true }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "reciver.protocols" -}}
{{- $service := .service }}{{- $localListenerIp := .localListenerIp }}{{- range .protocols }}{{- if and (eq .name $service) (.enabled )}}
{{- if eq .name "jaeger-http"}}thrift_http:{{- else if eq .name "jaeger-grpc" }}grpc:{{- else }}{{ .name }}:{{- end }}
  endpoint: {{ $localListenerIp }}:{{ .internalPort }}
    {{- if eq .name "grpc" }}
  max_recv_msg_size_mib: {{ .maxReceivedMessageSizeMiB }}
    {{- end }}
{{- end }}
    {{- end }}
{{- end }}

{{- define "reciver.exporters" }}
{{ $defaultHostname := printf "%s-%s-%s-service" .Values.global.name .Values.collector.metadata.name .Values.collector.specs.service.name }}
  loadbalancing:
    protocol:
      otlp:
        timeout: {{ .Values.receiver.specs.configuration.exporters.load_balancing.protocol.otlp.timeout }}
        tls:
          insecure: {{ .Values.receiver.specs.configuration.exporters.load_balancing.protocol.otlp.tls.insecure }}
    resolver:
      dns:
        hostname: {{ .Values.receiver.specs.configuration.exporters.load_balancing.protocol.resolver.dns.hostname | default $defaultHostname }}
        port: {{ .Values.receiver.specs.configuration.exporters.load_balancing.protocol.resolver.dns.port }}
{{- end }}

{{- define "reciver.configMap.services.telemetry" }}
{{ $service := .service }}{{ $localListenerIp := .localListenerIp }}{{- range .protocols }}
{{- if and (eq .name $service) ( .enabled )}}
telemetry:
  metrics:
    address: {{ $localListenerIp }}:{{ .internalPort }}
{{- end }}
{{- end }}
{{- end }}
