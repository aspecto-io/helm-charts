<p align='center'>
    <img src='../../assets/aspecto-io.png' width="50px" alt='Aspecto.io'/>
</p>
<p align='center'>
    Aspecto.io opentelemetry sampling collector
</p>


Welcome to the helm chart of the aspecto.io opentelemetry sampling collector.
___
## Description

The collector allows you to install traces collector on your kubernetes cluster and define rules of when the traces should be dropped and when they should be sent to your aspecto
___
## Table of Contents
- [](#)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [How to install](#how-to-install)
    - [Configuration](#configuration)
    - [Upgrading](#upgrading)
  - [Parameters](#parameters)
    - [Global](#global)
    - [Load-Balancer](#load-balancer)
    - [Sampling-Collector](#sampling-collector)
  - [Resource Planning](#resources-planning)

___
# Prerequisites
* Kubernetes 1.12+
* Helm 3.1.0 or higher
* Aspecto.io account and api token 

(*) we encourage you to use a DNS CNAME, it will ease on you possible changes in your deployment configuration with smaller footprint on production.
___
# How to install
1. add the aspecto.io help repo by running:
```bash
console helm repo add aspecto https://aspecto.github.io/opentelemetry-helm-charts
```

2. go to https://app.aspecto.io/app/integration/api-key and copy your api key 
3. run the install command: 
```bash
helm install opentelemetry-collector aspecto/opentelemetry-collector --set apiKey=YOUR_API_KEY
```
___
## Configuration
you can change the default values stored in the values file according to the specified configuration list bellow.
you can do that using the following options

1. pass new value using the set command
```bash
helm install --set <key>=<value>
```
2. change the content of the `values.yaml` file and run the helm install command without the set part.
3. create additional values file (e.g. production.yaml) and install the chart using the following command
```bash
helm install --name aspecto-collector -f values.yaml -f production.yaml
```
___
## Upgrading

In order to change configuration or upgrade please run the following command, the same aspects of set / file configuration applies here. 

```bash
helm upgrade --name aspecto-collector -f values.yaml -f production.yaml
```
___
# Parameters
## Global
_This section of parameters will be shared across all objects unless specified per service_
| Name | Description | Type/Options | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| global.`name` | Global prefix for objects (deployment/service/etc.) | string | empty | `true` |
| global.`namespace` | Default namespace for objects (deployment/service/etc.) | 
| global.`env` | Global environment variables | object | {} | false | string | empty | `true` |
| ***`Global.aspecto`*** : _aspecto configuration_ |
| global.aspecto.`apiToken` | api token for aspecto integration. for more information go here: https://app.aspecto.io/app/integration/api-key | string | | `true` |
| global.aspecto.`interval` | refresh rate to pull sampling configuration (in seconds) | number | 60 | `true` |
| global.aspecto.`existingSecret` | Should we use the API token already existing in the kube secrets | boolean | false | `true` |
| ***`Global.rolloutStrategy`*** : _deployment rollout configuration_ |
| global.rolloutStrategy.`type` | rolling deployment strategy | `Recreate` ,  `RollingUpdate` | RollingUpdate | `true` |
| global.rolloutStrategy.rollingUpdate.`maxUnavailable` | How many instances are allowed to be unavailable during the deployment | number | 0 | `true` |
| global.rolloutStrategy.rollingUpdate.`maxSurge` | How many instances should be spawned up before taking down existing instances | number | 2 | `true` |
| ***`Global.metadata`*** : _objects metada configuration_ |
| global.metadata.shared.`annotations` | Global annotations to be shared across all child objects | object | {} | false |
| global.metadata.shared.`labels` | Global labels to be shared across all child objects | object | {} | false |
| global.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`annotations` | Global annotations to be shared across all pods | object | {} | false |
| global.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`labels` | Global labels to be shared across all selected object | object | {} | false |
| ***`Global.image`*** : _global image configuration (will be overridden in case specified in service)_ |
| global.image.`repository` | Global repository to pull the image from | string | public.ecr.aws/x3s3n8k7 | false |
| global.image.`pullPolicy` | Global repository to pull the image from | `Always`, `Never`, `IfNotPresent` | Always | false |
| global.image.`version` | Global image to pull (we're using the same tag when new version is release and tested) | string | specified to latest stable version| false |
___
## load-balancer
_This section of parameters describes the load_balancer service_
| Name | Description | Type/Options | Default | Required |
| :--- | :--- | :---: | :---: | :---: |
| load_balancer.`env` | environment variables | object | {} | false | string | empty | `true` |
| ***`load_balancer.image`*** | _This section of parameters will be configure image policy. leaving values empty will populate values from the global section |
| load_balancer.image.`repository` | repository to pull the image from | string | public.ecr.aws/x3s3n8k7 | false |
| load_balancer.image.`pullPolicy` | repository to pull the image from | `Always`, `Never`, `IfNotPresent` | Always | false |
| load_balancer.image.`version` | image to pull (we're using the same tag when new version is release and tested) | string | specified to latest stable version | false |
| load_balancer.image.`name` | load balancing docker image name | string | otelcol-loadbalancing | `true` |
| ***`load_balancer.metadata`*** |
| load_balancer.metadata.shared.`annotations` | annotations to be shared across all child objects | object | {} | false |
| load_balancer.metadata.shared.`labels` | labels to be shared across all child objects | object | {} | false |
| load_balancer.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`annotations` | annotations to be shared across all pods | object | {} | false |
| load_balancer.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`labels` | labels to be shared across all selected object | object | {} | false |
| ***`load_balancer.specs`*** : _This section of parameters define resources over the service_ |
| ***`load_balancer.specs.configuration`*** : _service configuration_ |
| load_balancer.specs.configuration.exporters.load_balancing.protocol.otlp.`timeout` | timeout of connection in case of no response | string | 1s | `true` |
| load_balancer.specs.configuration.exporters.load_balancing.protocol.otlp.tls.`insecure` | connection over TLS should verify certificate | boolean | false | `true` |
| load_balancer.specs.configuration.exporters.load_balancing.protocol.resolver.dns.`hostname` | sampling service endpoint | string | otel-collector-opentelemetry-sampling-service | false |
| load_balancer.specs.configuration.exporters.load_balancing.protocol.resolver.dns.`port` | sampling service grpc port number | number | 4317 | `true` |
| load_balancer.specs.configuration.log.`enable` | should turn on logger | boolean | false | false | 
| load_balancer.specs.configuration.log.`level` | log level | `fatal`, `error`, `info`, `debug` | error | false |
| load_balancer.specs.configuration.`endpoint` | endpoint for virtual service | string | '' | false |
| ***`load_balancer.specs.autoscaling`*** : _hpa/autoscaling configuration_ |
| load_balancer.specs.autoscaling.`enable` | Turn on autoscaling | boolean | true | `true` |
| load_balancer.specs.autoscaling.`defaultReplicaCount` | replicaCount in case not using HPA | number | 3 | `true` |
| load_balancer.specs.autoscaling.`minReplicas` | minimum amount of pods | number | 3 | false |
| load_balancer.specs.autoscaling.`maxReplicas` | maximum amount of pods | number | 20 | false |
| load_balancer.specs.autoscaling.`targetCPUUtilizationPercentage` | CPU consumption percentage threshold before creating more pods | number | 75 | false | 
| load_balancer.specs.autoscaling.`targetMemoryUtilizationPercentage` | Memory consumption percentage threshold before creating more pods | number | 75 | false |
| ***`load_balancer.specs.resources`*** : _resources configuration_ |
| load_balancer.specs.resources..limits.`cpu` | Amount of cores to allocate to the pod (hard limit) | number | 2 | `true` |
| load_balancer.specs.resources.limits.`memory` | Amount of memory to allocate to the pod (hard limit) | string | 2Gi | `true` |
| load_balancer.specs.resources.requests.`cpu` | Amount of cores to allocate to the pod (soft limit) | number | 1 | `true` |
| load_balancer.specs.resources.requests.`memory` | Amount of cores to allocate to the pod (soft limit) | string | 1Gi | `true` |
| ***`load_balancer.specs.probe`*** : _pod state monitoring_ |
| load_balancer.specs.probe.readinessProbe.httpGet.`path` | (Readiness) HTTP uri to run health-check against | string | / | `true` |
| load_balancer.specs.probe.readinessProbe.httpGet.`port` | (Readiness) HTTP port to run health-check against | number | 8090 | `true` |
| load_balancer.specs.probe.readinessProbe.`initialDelaySeconds` | (Readiness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| load_balancer.specs.probe.readinessProbe.`periodSeconds` | (Readiness) TTL of request to probe the state | number | 3 | `true` |
| load_balancer.specs.probe.livenessProbe.httpGet.`path` | (Liveness) HTTP uri to run health-check against | string | / | `true` |
| load_balancer.specs.probe.livenessProbe.httpGet.`port` | (Liveness) HTTP port to run health-check against | number | 8090 | `true` |
| load_balancer.specs.probe.livenessProbe.`initialDelaySeconds` | (Liveness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| load_balancer.specs.probe.livenessProbe.`periodSeconds` | (Liveness) TTL of request to probe the state | number | 3 | `true` |
| ***`load_balancer.specs.volumes`*** : _pod volumes configuration_ |
| load_balancer.specs.volumes.serviceConfig.`name` | Volume name | string | otel-lb-config | `true` |
| load_balancer.specs.volumes.serviceConfig.`mountPath` | mount folder location (name) | string | /config | `true` |
| load_balancer.specs.volumes.serviceConfig.`fileName` | configuration file name | string | config.yaml | `true` |
| load_balancer.specs.volumes.`extraVolumes` | array of additional volumes | [] | [] | false |
| load_balancer.specs.volumes.extraVolumes.`name` | volume name | string | | false |
| load_balancer.specs.volumes.extraVolumes.`mountPath` | mount folder path | string | | false |
| load_balancer.specs.volumes.extraVolumes.`subPath` | filename | string | | false |
| load_balancer.specs.volumes.`extraSecretMounts` | array of additional secrets volumes | [] | [] | false |
| load_balancer.specs.volumes.extraSecretMounts.[].`name` | volume name | string | | false |
| load_balancer.specs.volumes.extraSecretMounts.[].`mountPath` | file location in the pod | string | | false |
| load_balancer.specs.volumes.extraSecretMounts.[].`secretName` | secret name | string | | false |
| load_balancer.specs.volumes.extraSecretMounts.[].`readOnly` | should use readOnly mount | boolean | true | false |
| ***`load_balancer.specs.network`*** : _pod network configuration_ | default configuration already applied | 
| load_balancer.specs.network.`localListenerIp` | IP address the application should accept requests from | string | 0.0.0.0 | `true` |
| load_balancer.specs.network.`type` | Network type | string | None | `true` |
| load_balancer.specs.network.`ports` | Port configuration array | [] | [] | `true` |
| load_balancer.specs.network.ports.[].`name` | Port name | string | grpc | `true` |
| load_balancer.specs.network.ports.[].`internalPort` | egress port number | number | 4317 | `true` |
| load_balancer.specs.network.ports.[].`externalPort` | ingress port number | number | 4317 | `true` |
| load_balancer.specs.network.ports.[].`protocol` | Port protocol | `TCP`, `UDP`, `ICMP` | TCP | `true` |
| load_balancer.specs.network.istio.`enable` | Should enable istio | boolean | false | `true` |
| load_balancer.specs.network.istio.`rules` | istio rules | [] | [] | false |
| ***`load_balancer.specs.services`*** : _service configuration_ |
| load_balancer.specs.service.[].`name` | Service name | string | opentelemetry-sampling-load-balancer | `true` |
| load_balancer.specs.service.[].`serviceType` | Service type | `LoadBalancer`, `ClusterIP` | LoadBalancer | `true` |
| load_balancer.specs.service.[].`selector` | key:value of pod labels | {} | component: otel-collector-load-balancer-pod | `true` |
| load_balancer.specs.service.[].`ports` | service exposed ports | [] | (default configuration provided) | `true` |
| load_balancer.specs.service.[].ports.[].`name` | port name | string | grpc | `true` |
| load_balancer.specs.service.[].ports.[].`type` | port type | string | grpc | `true` |
| load_balancer.specs.service.[].ports.[].`externalPort` | external port number | number | 4318 | `true` |
| load_balancer.specs.service.[].ports.[].`internalPort` | internal port number | number | 4318 | `true` |
| load_balancer.specs.service.[].ports.[].`protocol` | port protocol | `TCP`, `UDP`, `ICMP` | TCP | false |
| load_balancer.specs.service.[].ports.[].`loadBalancer` | routing mechanism | object | simple: LEAST_CONN | `true` |
___
## Sampling-Collector
_This section of parameters describes the  sampling_collector service_
| Name | Description | Type/Options | Default | Required |
| :--- | :--- | :---: | :---: | :---: |
| sampling_collector.`env` | environment variables | object | {} | false | string | empty | `true` |
| ***` sampling_collector.image`*** | _This section of parameters will be configure image policy. leaving values empty will populate values from the global section |
| sampling_collector.image.`repository` | repository to pull the image from | string | public.ecr.aws/x3s3n8k7 | false |
| sampling_collector.image.`pullPolicy` | repository to pull the image from | `Always`, `Never`, `IfNotPresent` | Always | false |
| sampling_collector.image.`version` | image to pull (we're using the same tag when new version is release and tested) | string | specified to latest stable version | false |
| sampling_collector.image.`name` | load balancing docker image name | string | otelcol-sampling | `true` |
| ***` sampling_collector.metadata`*** |
| sampling_collector.metadata.shared.`annotations` | annotations to be shared across all child objects | object | {} | false |
| sampling_collector.metadata.shared.`labels` | labels to be shared across all child objects | object | {} | false |
| sampling_collector.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`annotations` | annotations to be shared across all pods | object | {} | false |
| sampling_collector.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`labels` | labels to be shared across all selected object | object | {} | false |
| ***` sampling_collector.specs`*** : _This section of parameters define resources over the service_ |
| ***` sampling_collector.specs.configuration`*** : _service configuration_ |
| sampling_collector.specs.configuration.`endpoint` | timeout of connection in case of no response | string | 1s | `true` |
| sampling_collector.specs.configuration.`decision_wait` | number of seconds to wait before closing the trace | string | 10s | `true` |
| sampling_collector.specs.configuration.`num_traces` | number of traces to hold in the memory | number | 100 | `true` |
| sampling_collector.specs.configuration.`expected_new_traces_per_sec` | number of expected traces per seconds | number | 10 | `true` |
| sampling_collector.specs.configuration.`policies` | policy name (aspecto mapping | string | $$aspecto:tail_sampling_policy | `true` |
| sampling_collector.specs.configuration.log.`enable` | should enable logging | boolean | false | false |
| sampling_collector.specs.configuration.log.`level`  | log level | `fatal`, `error`, `info`, `debug` | error | false |
| ***` sampling_collector.specs.autoscaling`*** : _hpa/autoscaling configuration_ |
| sampling_collector.specs.autoscaling.`enable` | Turn on autoscaling | boolean | true | `true` |
| sampling_collector.specs.autoscaling.`defaultReplicaCount` | replicaCount in case not using HPA | number | 3 | `true` |
| sampling_collector.specs.autoscaling.`minReplicas` | minimum amount of pods | number | 3 | false |
| sampling_collector.specs.autoscaling.`maxReplicas` | maximum amount of pods | number | 20 | false |
| sampling_collector.specs.autoscaling.`targetCPUUtilizationPercentage` | CPU consumption percentage threshold before creating more pods | number | 75 | false | 
| sampling_collector.specs.autoscaling.`targetMemoryUtilizationPercentage` | Memory consumption percentage threshold before creating more pods | number | 75 | false |
| ***` sampling_collector.specs.resources`*** : _resources configuration_ |
| sampling_collector.specs.resources..limits.`cpu` | Amount of cores to allocate to the pod (hard limit) | number | 2 | `true` |
| sampling_collector.specs.resources.limits.`memory` | Amount of memory to allocate to the pod (hard limit) | string | 2Gi | `true` |
| sampling_collector.specs.resources.requests.`cpu` | Amount of cores to allocate to the pod (soft limit) | number | 1 | `true` |
| sampling_collector.specs.resources.requests.`memory` | Amount of cores to allocate to the pod (soft limit) | string | 1Gi | `true` |
| ***` sampling_collector.specs.probe`*** : _pod state monitoring_ |
| sampling_collector.specs.probe.readinessProbe.httpGet.`path` | (Readiness) HTTP uri to run health-check against | string | / | `true` |
| sampling_collector.specs.probe.readinessProbe.httpGet.`port` | (Readiness) HTTP port to run health-check against | number | 8090 | `true` |
| sampling_collector.specs.probe.readinessProbe.`initialDelaySeconds` | (Readiness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| sampling_collector.specs.probe.readinessProbe.`periodSeconds` | (Readiness) TTL of request to probe the state | number | 3 | `true` |
| sampling_collector.specs.probe.livenessProbe.httpGet.`path` | (Liveness) HTTP uri to run health-check against | string | / | `true` |
| sampling_collector.specs.probe.livenessProbe.httpGet.`port` | (Liveness) HTTP port to run health-check against | number | 8090 | `true` |
| sampling_collector.specs.probe.livenessProbe.`initialDelaySeconds` | (Liveness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| sampling_collector.specs.probe.livenessProbe.`periodSeconds` | (Liveness) TTL of request to probe the state | number | 3 | `true` |
| ***` sampling_collector.specs.volumes`*** : _pod volumes configuration_ |
| sampling_collector.specs.volumes.serviceConfig.`name` | Volume name | string | otel-lb-config | `true` |
| sampling_collector.specs.volumes.serviceConfig.`mountPath` | mount folder location (name) | string | /config | `true` |
| sampling_collector.specs.volumes.serviceConfig.`fileName` | configuration file name | string | config.yaml | `true` |
| sampling_collector.specs.volumes.`extraVolumes` | array of additional volumes | [] | [] | false |
| sampling_collector.specs.volumes.extraVolumes.`name` | volume name | string | | false |
| sampling_collector.specs.volumes.extraVolumes.`mountPath` | mount folder path | string | | false |
| sampling_collector.specs.volumes.extraVolumes.`subPath` | filename | string | | false |
| sampling_collector.specs.volumes.`extraSecretMounts` | array of additional secrets volumes | [] | [] | false |
| sampling_collector.specs.volumes.extraSecretMounts.[].`name` | volume name | string | | false |
| sampling_collector.specs.volumes.extraSecretMounts.[].`mountPath` | file location in the pod | string | | false |
| sampling_collector.specs.volumes.extraSecretMounts.[].`secretName` | secret name | string | | false |
| sampling_collector.specs.volumes.extraSecretMounts.[].`readOnly` | should use readOnly mount | boolean | true | false |
| ***` sampling_collector.specs.network`*** : _pod network configuration_ | default configuration already applied | 
| sampling_collector.specs.network.`localListenerIp` | IP address the application should accept requests from | string | 0.0.0.0 | `true` |
| sampling_collector.specs.network.`type` | Network type | string | None | `true` |
| sampling_collector.specs.network.`ports` | Port configuration array | [] | [] | `true` |
| sampling_collector.specs.network.ports.[].`name` | Port name | string | grpc | `true` |
| sampling_collector.specs.network.ports.[].`internalPort` | egress port number | number | 4317 | `true` |
| sampling_collector.specs.network.ports.[].`externalPort` | ingress port number | number | 4317 | `true` |
| sampling_collector.specs.network.ports.[].`protocol` | Port protocol | `TCP`, `UDP`, `ICMP` | TCP | `true` |
| sampling_collector.specs.network.istio.`enable` | Should enable istio | boolean | false | `true` |
| sampling_collector.specs.network.istio.`rules` | istio rules | [] | [] | false |
| ***` sampling_collector.specs.services`*** : _service configuration_ |
| sampling_collector.specs.service.[].`name` | Service name | string | opentelemetry-sampling | `true` |
| sampling_collector.specs.service.[].`serviceType` | Service type | `LoadBalancer`, `ClusterIP` | ClusterIP | `true` |
| sampling_collector.specs.service.[].`selector` | key:value of pod labels | {} | component: otel-collector-load-balancer-pod | `true` |
| sampling_collector.specs.service.[].`ports` | service exposed ports | [] | (default configuration provided) | `true` |
| sampling_collector.specs.service.[].ports.[].`name` | port name | string | grpc | `true` |
| sampling_collector.specs.service.[].ports.[].`type` | port type | string | grpc | `true` |
| sampling_collector.specs.service.[].ports.[].`externalPort` | external port number | number | 8081 | `true` |
| sampling_collector.specs.service.[].ports.[].`internalPort` | internal port number | number | 4318 | `true` |
| sampling_collector.specs.service.[].ports.[].`protocol` | port protocol | `TCP`, `UDP`, `ICMP` | TCP | false |
| sampling_collector.specs.service.[].ports.[].`loadBalancer` | routing mechanism | object | simple: LEAST_CONN | `true` |
___
# Resources planning

We suggest following the general guidelines provided by the otel community, as listed below.
You are always welcome to re-check for the latest stress-test results. 

| Span<br>Format    | CPU<br>(2+ GHz) | RAM<br>(GB) | Sustained<br>Rate | Recommended<br>Maximum |
| :---:             | :---:           | :---:       | :---:             | :---:                  |
| OpenTelemetry        | 1               | 2           | ~9K               | 8K                     |
| OpenTelemetry        | 2               | 4           | ~18K              | 16K                    |


[Source - OpenTelemetry Collector Performance](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/performance.md)