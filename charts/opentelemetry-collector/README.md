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
    - [receiver](#receiver)
    - [collector](#collector)
    - [redis](#redis)
  - [Resource Planning](#resources-planning)

___
# Prerequisites
* Kubernetes 1.12+
* Helm 3.1.0 or higher
* Aspecto.io account and api token (which will be mapped in the environment variables of the collector)

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
helm install --name aspecto-collector aspecto/aspecto-io-opentelemetry-collector --set global.aspecto.token.value="<token>"
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
| global.`env` | Global environment variables | object | {} | false | string | empty | `true` |
| ***`Global.aspecto`*** : _aspecto configuration_ |
| global.aspecto.`interval` | refresh rate to pull sampling configuration (in seconds) | number | 60 | `true` |
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
## receiver
_This section of parameters describes the receiver service_
| Name | Description | Type/Options | Default | Required |
| :--- | :--- | :---: | :---: | :---: |
| receiver.`env` | environment variables | object | {} | false | string | empty | `true` |
| ***`receiver.image`*** | _This section of parameters will be configure image policy. leaving values empty will populate values from the global section |
| receiver.image.`repository` | repository to pull the image from | string | public.ecr.aws/x3s3n8k7 | false |
| receiver.image.`pullPolicy` | repository to pull the image from | `Always`, `Never`, `IfNotPresent` | Always | false |
| receiver.image.`version` | image to pull (we're using the same tag when new version is release and tested) | string | specified to latest stable version | false |
| receiver.image.`name` | load balancing docker image name | string | otelcol-loadbalancing | `true` |
| ***`receiver.metadata`*** |
| receiver.metadata.shared.`annotations` | annotations to be shared across all child objects | object | {} | false |
| receiver.metadata.shared.`labels` | labels to be shared across all child objects | object | {} | false |
| receiver.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`annotations` | annotations to be shared across all pods | object | {} | false |
| receiver.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`labels` | labels to be shared across all selected object | object | {} | false |
| ***` receiver.envs`*** : _This section of parameters define environment variables._ |
| receiver.envs | environment variables that will be defined on the deployment pods. value can be defined from any source (static, value, etc.) | array | [] | true |
| receiver.envsFrom | environment variables that which will be imported and defined on the deployment pods. | array | [] | true |
| ***`receiver.specs`*** : _This section of parameters define resources over the service_ |
| ***`receiver.specs.configuration`*** : _service configuration_ |
| receiver.specs.configuration.exporters.load_balancing.protocol.otlp.`timeout` | timeout of connection in case of no response | string | 1s | `true` |
| receiver.specs.configuration.exporters.load_balancing.protocol.otlp.tls.`insecure` | connection over TLS should verify certificate | boolean | false | `true` |
| receiver.specs.configuration.exporters.load_balancing.protocol.resolver.dns.`hostname` | sampling service endpoint | string | otel-collector-opentelemetry-sampling-service | false |
| receiver.specs.configuration.exporters.load_balancing.protocol.resolver.dns.`port` | sampling service grpc port number | number | 4317 | `true` |
| receiver.specs.configuration.log.`enable` | should turn on logger | boolean | false | false | 
| receiver.specs.configuration.log.`level` | log level | `fatal`, `error`, `info`, `debug` | error | false |
| receiver.specs.configuration.`endpoint` | endpoint for virtual service | string | '' | false |
| ***`receiver.specs.autoscaling`*** : _hpa/autoscaling configuration_ |
| receiver.specs.autoscaling.`enable` | Turn on autoscaling | boolean | true | `true` |
| receiver.specs.autoscaling.`defaultReplicaCount` | replicaCount in case not using HPA | number | 3 | `true` |
| receiver.specs.autoscaling.`minReplicas` | minimum amount of pods | number | 3 | false |
| receiver.specs.autoscaling.`maxReplicas` | maximum amount of pods | number | 20 | false |
| receiver.specs.autoscaling.`targetCPUUtilizationPercentage` | CPU consumption percentage threshold before creating more pods | number | 75 | false | 
| receiver.specs.autoscaling.`targetMemoryUtilizationPercentage` | Memory consumption percentage threshold before creating more pods | number | 75 | false |
| ***`receiver.specs.resources`*** : _resources configuration_ |
| receiver.specs.resources..limits.`cpu` | Amount of cores to allocate to the pod (hard limit) | number | 2 | `true` |
| receiver.specs.resources.limits.`memory` | Amount of memory to allocate to the pod (hard limit) | string | 2Gi | `true` |
| receiver.specs.resources.requests.`cpu` | Amount of cores to allocate to the pod (soft limit) | number | 1 | `true` |
| receiver.specs.resources.requests.`memory` | Amount of cores to allocate to the pod (soft limit) | string | 1Gi | `true` |
| ***`receiver.specs.probe`*** : _pod state monitoring_ |
| receiver.specs.probe.readinessProbe.httpGet.`path` | (Readiness) HTTP uri to run health-check against | string | / | `true` |
| receiver.specs.probe.readinessProbe.httpGet.`port` | (Readiness) HTTP port to run health-check against | number | 8090 | `true` |
| receiver.specs.probe.readinessProbe.`initialDelaySeconds` | (Readiness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| receiver.specs.probe.readinessProbe.`periodSeconds` | (Readiness) TTL of request to probe the state | number | 3 | `true` |
| receiver.specs.probe.livenessProbe.httpGet.`path` | (Liveness) HTTP uri to run health-check against | string | / | `true` |
| receiver.specs.probe.livenessProbe.httpGet.`port` | (Liveness) HTTP port to run health-check against | number | 8090 | `true` |
| receiver.specs.probe.livenessProbe.`initialDelaySeconds` | (Liveness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| receiver.specs.probe.livenessProbe.`periodSeconds` | (Liveness) TTL of request to probe the state | number | 3 | `true` |
| ***`receiver.specs.volumes`*** : _pod volumes configuration_ |
| receiver.specs.volumes.serviceConfig.`name` | Volume name | string | otel-lb-config | `true` |
| receiver.specs.volumes.serviceConfig.`mountPath` | mount folder location (name) | string | /config | `true` |
| receiver.specs.volumes.serviceConfig.`fileName` | configuration file name | string | config.yaml | `true` |
| receiver.specs.volumes.`extraVolumes` | array of additional volumes | [] | [] | false |
| receiver.specs.volumes.extraVolumes.`name` | volume name | string | | false |
| receiver.specs.volumes.extraVolumes.`mountPath` | mount folder path | string | | false |
| receiver.specs.volumes.extraVolumes.`subPath` | filename | string | | false |
| receiver.specs.volumes.`extraSecretMounts` | array of additional secrets volumes | [] | [] | false |
| receiver.specs.volumes.extraSecretMounts.[].`name` | volume name | string | | false |
| receiver.specs.volumes.extraSecretMounts.[].`mountPath` | file location in the pod | string | | false |
| receiver.specs.volumes.extraSecretMounts.[].`secretName` | secret name | string | | false |
| receiver.specs.volumes.extraSecretMounts.[].`readOnly` | should use readOnly mount | boolean | true | false |
| ***`receiver.specs.network`*** : _pod network configuration_ | default configuration already applied | 
| receiver.specs.network.`localListenerIp` | IP address the application should accept requests from | string | 0.0.0.0 | `true` |
| receiver.specs.network.`type` | Network type | string | None | `true` |
| receiver.specs.network.`ports` | Port configuration array | [] | [] | `true` |
| receiver.specs.network.ports.[].`name` | Port name | string | grpc | `true` |
| receiver.specs.network.ports.[].`internalPort` | egress port number | number | 4317 | `true` |
| receiver.specs.network.ports.[].`externalPort` | ingress port number | number | 4317 | `true` |
| receiver.specs.network.ports.[].`protocol` | Port protocol | `TCP`, `UDP`, `ICMP` | TCP | `true` |
| receiver.specs.network.istio.`enable` | Should enable istio | boolean | false | `true` |
| receiver.specs.network.istio.`rules` | istio rules | [] | [] | false |
| ***`receiver.specs.services`*** : _service configuration_ |
| receiver.specs.service.[].`name` | Service name | string | opentelemetry-sampling-receiver | `true` |
| receiver.specs.service.[].`serviceType` | Service type | `LoadBalancer`, `ClusterIP` | LoadBalancer | `true` |
| receiver.specs.service.[].`selector` | key:value of pod labels | {} | component: otel-receiver-pod | `true` |
| receiver.specs.service.[].`ports` | service exposed ports | [] | (default configuration provided) | `true` |
| receiver.specs.service.[].ports.[].`name` | port name | string | grpc | `true` |
| receiver.specs.service.[].ports.[].`type` | port type | string | grpc | `true` |
| receiver.specs.service.[].ports.[].`externalPort` | external port number | number | 4318 | `true` |
| receiver.specs.service.[].ports.[].`internalPort` | internal port number | number | 4318 | `true` |
| receiver.specs.service.[].ports.[].`protocol` | port protocol | `TCP`, `UDP`, `ICMP` | TCP | false |
| receiver.specs.service.[].ports.[].`loadBalancer` | routing mechanism | object | simple: LEAST_CONN | `true` |
___
## collector
_This section of parameters describes the  collector service_
| Name | Description | Type/Options | Default | Required |
| :--- | :--- | :---: | :---: | :---: |
| collector.`env` | environment variables | object | {} | false | string | empty | `true` |
| ***` collector.image`*** | _This section of parameters will be configure image policy. leaving values empty will populate values from the global section |
| collector.image.`repository` | repository to pull the image from | string | public.ecr.aws/x3s3n8k7 | false |
| collector.image.`pullPolicy` | repository to pull the image from | `Always`, `Never`, `IfNotPresent` | Always | false |
| collector.image.`version` | image to pull (we're using the same tag when new version is release and tested) | string | specified to latest stable version | false |
| collector.image.`name` | load balancing docker image name | string | otelcol-sampling | `true` |
| ***` collector.metadata`*** |
| collector.metadata.shared.`annotations` | annotations to be shared across all child objects | object | {} | false |
| collector.metadata.shared.`labels` | labels to be shared across all child objects | object | {} | false |
| collector.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`annotations` | annotations to be shared across all pods | object | {} | false |
| collector.metadata.{pod/deployment/service/configMap/hpa/virtualService/destinationRule}.`labels` | labels to be shared across all selected object | object | {} | false |
| ***` collector.envs`*** : _This section of parameters define environment variables._ |
| collector.envs | environment variables that will be defined on the deployment pods. one of them must be the token variable. value can be defined from any source (static, value, etc.) | array | [] | true |
| collector.envsFrom | environment variables that which will be imported and defined on the deployment pods. | array | [] | true |
| ***` collector.specs`*** : _This section of parameters define resources over the service_ |
| ***` collector.specs.configuration`*** : _service configuration_ |
| collector.specs.configuration.`endpoint` | timeout of connection in case of no response | string | 1s | `true` |
| collector.specs.configuration.`decision_wait` | number of seconds to wait before closing the trace | string | 10s | `true` |
| collector.specs.configuration.`num_traces` | number of traces to hold in the memory | number | 100 | `true` |
| collector.specs.configuration.`expected_new_traces_per_sec` | number of expected traces per seconds | number | 10 | `true` |
| collector.specs.configuration.`policies` | policy name (aspecto mapping | string | $$aspecto:tail_sampling_policy | `true` |
| collector.specs.configuration.log.`enable` | should enable logging | boolean | false | false |
| collector.specs.configuration.log.`level`  | log level | `fatal`, `error`, `info`, `debug` | error | false |
| ***` collector.specs.autoscaling`*** : _hpa/autoscaling configuration_ |
| collector.specs.autoscaling.`enable` | Turn on autoscaling | boolean | true | `true` |
| collector.specs.autoscaling.`defaultReplicaCount` | replicaCount in case not using HPA | number | 3 | `true` |
| collector.specs.autoscaling.`minReplicas` | minimum amount of pods | number | 3 | false |
| collector.specs.autoscaling.`maxReplicas` | maximum amount of pods | number | 20 | false |
| collector.specs.autoscaling.`targetCPUUtilizationPercentage` | CPU consumption percentage threshold before creating more pods | number | 75 | false | 
| collector.specs.autoscaling.`targetMemoryUtilizationPercentage` | Memory consumption percentage threshold before creating more pods | number | 75 | false |
| ***` collector.specs.resources`*** : _resources configuration_ |
| collector.specs.resources..limits.`cpu` | Amount of cores to allocate to the pod (hard limit) | number | 2 | `true` |
| collector.specs.resources.limits.`memory` | Amount of memory to allocate to the pod (hard limit) | string | 2Gi | `true` |
| collector.specs.resources.requests.`cpu` | Amount of cores to allocate to the pod (soft limit) | number | 1 | `true` |
| collector.specs.resources.requests.`memory` | Amount of cores to allocate to the pod (soft limit) | string | 1Gi | `true` |
| ***` collector.specs.probe`*** : _pod state monitoring_ |
| collector.specs.probe.readinessProbe.httpGet.`path` | (Readiness) HTTP uri to run health-check against | string | / | `true` |
| collector.specs.probe.readinessProbe.httpGet.`port` | (Readiness) HTTP port to run health-check against | number | 8090 | `true` |
| collector.specs.probe.readinessProbe.`initialDelaySeconds` | (Readiness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| collector.specs.probe.readinessProbe.`periodSeconds` | (Readiness) TTL of request to probe the state | number | 3 | `true` |
| collector.specs.probe.livenessProbe.httpGet.`path` | (Liveness) HTTP uri to run health-check against | string | / | `true` |
| collector.specs.probe.livenessProbe.httpGet.`port` | (Liveness) HTTP port to run health-check against | number | 8090 | `true` |
| collector.specs.probe.livenessProbe.`initialDelaySeconds` | (Liveness) How many seconds to wait before first request to probe the state | number | 10 | `true` |
| collector.specs.probe.livenessProbe.`periodSeconds` | (Liveness) TTL of request to probe the state | number | 3 | `true` |
| ***` collector.specs.volumes`*** : _pod volumes configuration_ |
| collector.specs.volumes.serviceConfig.`name` | Volume name | string | otel-lb-config | `true` |
| collector.specs.volumes.serviceConfig.`mountPath` | mount folder location (name) | string | /config | `true` |
| collector.specs.volumes.serviceConfig.`fileName` | configuration file name | string | config.yaml | `true` |
| collector.specs.volumes.`extraVolumes` | array of additional volumes | [] | [] | false |
| collector.specs.volumes.extraVolumes.`name` | volume name | string | | false |
| collector.specs.volumes.extraVolumes.`mountPath` | mount folder path | string | | false |
| collector.specs.volumes.extraVolumes.`subPath` | filename | string | | false |
| collector.specs.volumes.`extraSecretMounts` | array of additional secrets volumes | [] | [] | false |
| collector.specs.volumes.extraSecretMounts.[].`name` | volume name | string | | false |
| collector.specs.volumes.extraSecretMounts.[].`mountPath` | file location in the pod | string | | false |
| collector.specs.volumes.extraSecretMounts.[].`secretName` | secret name | string | | false |
| collector.specs.volumes.extraSecretMounts.[].`readOnly` | should use readOnly mount | boolean | true | false |
| ***` collector.specs.network`*** : _pod network configuration_ | default configuration already applied | 
| collector.specs.network.`localListenerIp` | IP address the application should accept requests from | string | 0.0.0.0 | `true` |
| collector.specs.network.`type` | Network type | string | None | `true` |
| collector.specs.network.`ports` | Port configuration array | [] | [] | `true` |
| collector.specs.network.ports.[].`name` | Port name | string | grpc | `true` |
| collector.specs.network.ports.[].`internalPort` | egress port number | number | 4317 | `true` |
| collector.specs.network.ports.[].`externalPort` | ingress port number | number | 4317 | `true` |
| collector.specs.network.ports.[].`protocol` | Port protocol | `TCP`, `UDP`, `ICMP` | TCP | `true` |
| collector.specs.network.istio.`enable` | Should enable istio | boolean | false | `true` |
| collector.specs.network.istio.`rules` | istio rules | [] | [] | false |
| ***` collector.specs.services`*** : _service configuration_ |
| collector.specs.service.[].`name` | Service name | string | opentelemetry-sampling | `true` |
| collector.specs.service.[].`serviceType` | Service type | `LoadBalancer`, `ClusterIP` | ClusterIP | `true` |
| collector.specs.service.[].`selector` | key:value of pod labels | {} | component: otel-receiver-pod | `true` |
| collector.specs.service.[].`ports` | service exposed ports | [] | (default configuration provided) | `true` |
| collector.specs.service.[].ports.[].`name` | port name | string | grpc | `true` |
| collector.specs.service.[].ports.[].`type` | port type | string | grpc | `true` |
| collector.specs.service.[].ports.[].`externalPort` | external port number | number | 8081 | `true` |
| collector.specs.service.[].ports.[].`internalPort` | internal port number | number | 4318 | `true` |
| collector.specs.service.[].ports.[].`protocol` | port protocol | `TCP`, `UDP`, `ICMP` | TCP | false |
| collector.specs.service.[].ports.[].`loadBalancer` | routing mechanism | object | simple: LEAST_CONN | `true` |
___

## redis
_This section of parameters describes the redis service_

_redis is used for taking linked traces sampling decisions across multiple collector instances_
| Name | Description | Type/Options | Default | Required |
| :--- | :--- | :---: | :---: | :---: |
| redis.enabled | enable/disable linked traces sampling decisions | boolean | false | `true` |
| ***`redis.config`*** | _This section of parameters will configure linked traces redis policy_ |
| redis.config.`type` | redis type, local means starting a redis deployment as part of this chart, external means to use an external redis (you should use external in cases of very high throughput) | `local`, `external` | string | local | false |
| redis.config.`endpoint` | redis endpoint - only relevant in case of using `external` type | string | '' | false |
| redis.config.`ttlMinutes` | redis item ttl in minutes - it means that the linked trace sampling decision need to take place before this ttl | number | 5 | false |
| ***`redis.config.credentials`*** | _Configure redis username and password_ |
| redis.config.credentials.`username` | redis username | string | '' | false |
| redis.config.credentials.`password` | redis password | string | '' | false |
| ***`redis.config.credentials.secret`*** | _In case we want to use known secrets_ |
| redis.config.credentials.secret.`name` | secret name  | string | '' | false |
| redis.config.credentials.secret.`username_key` | secret username key  | string | '' | false |
| redis.config.credentials.secret.`password_key` | secret name  | string | '' | false |
| ***`redis.metadata`*** | _objects metadata configuration_ |
| redis.metadata.`annotations` | annotations to be shared across all child objects | object | {} | false |
| redis.metadata.`labels` | labels to be shared across all child objects | object | {} | false |
| ***`redis.spec`*** | _This section of parameters define resources over the service_ |
| redis.spec.`replicas` | deployment replica count | number | 1 | false |
| redis.spec.`port` | redis port | string | 6379 | false |
| ***`redis.spec.image`*** | _This section of parameters define image resources_ |
| redis.spec.image.`policy` | Pull image policy |`Always`, `Never`, `IfNotPresent` | Always | false |
| redis.spec.image.`name` | Image name | redis | false |
| redis.spec.image.`version` | Image version | 6.0.8 | false |
| ***`redis.spec.resources`*** | _resources configuration_ |
| redis.spec.resources.limits.`cpu` | Amount of cores to allocate to the pod (hard limit) | number | 1 | false |
| redis.spec.resources.limits.`memory` | Amount of memory to allocate to the pod (hard limit) | string | 2Gi | false |
| redis.spec.resources.requests.`cpu` | Amount of cores to allocate to the pod (soft limit) | number | 0.5 | false |
| redis.spec.resources.requests.`memory` | Amount of cores to allocate to the pod (soft limit) | string | 2Gi | false |

___
# Resources planning

We suggest following the general guidelines provided by the otel community, as listed below.
You are always welcome to re-check for the latest stress-test results. 

| Span<br>Format    | CPU<br>(2+ GHz) | RAM<br>(GB) | Sustained<br>Rate | Recommended<br>Maximum |
| :---:             | :---:           | :---:       | :---:             | :---:                  |
| OpenTelemetry        | 1               | 2           | ~9K               | 8K                     |
| OpenTelemetry        | 2               | 4           | ~18K              | 16K                    |


[Source - OpenTelemetry Collector Performance](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/performance.md)
