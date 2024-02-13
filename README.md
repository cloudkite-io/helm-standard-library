# Cloudkite Helm Standard Library.

## To use in helm chart
Chart.yaml:
```
apiVersion: v2
name: some-chart
description: some description
type: application
version: 1.0.0
dependencies:
  - name: standard-app
    version: 0.3.0
    repository: oci://us-central1-docker.pkg.dev/cloudkite-public/public-helm-charts
```
values.yaml:
```
standard-app:
  image: ...
  tag: ...
  apps:
    app1:
  ...
```

`example.values.yaml` serves as an ultimate library of all parameters