<p align='center'>
    <img src='assets/aspecto-io.png' width="50px" alt='Aspecto.io'/>
</p>
<p align='center'>
    Aspecto.io helm chart repo
</p>

## Description

This repo hold different helm charts provided by aspecto to ensure easier deployment and maintenance of your kubernetes deployments
___
## Table of Contents
- [](#)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [How to install](#how-to-install)
  - [Charts](#charts)
___
## Prerequisites
* Kubernetes 1.12+
* Helm 3.1.0 or higher
___
## How to install the helm repo
1. add the aspecto.io help repo by running:
```bash
console helm repo add aspecto https://aspecto.github.io/opentelemetry-helm-charts
```

## Charts
1. [opentelemetry-collector](charts/opentelemetry-collector/README.md)