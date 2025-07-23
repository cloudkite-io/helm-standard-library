{{- define "standard-app.externalSecret" -}}
{{- $name := .name }}
{{- $userLabels := .labels | default dict }}
{{- $globalLabels := $.Values.labels | default dict }}
{{- $defaultLabels := dict "product" $.Release.Name }}
{{- $labels := merge $defaultLabels $globalLabels $userLabels }}
{{- $secrets := .secrets }}
{{- $type := .type }}
{{- $storeName := .storeName }}
{{- $secretPath := .secretPath }}
{{- $refreshInterval := .refreshInterval | default "1m" }}

apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ $name }}
  labels:
    {{- toYaml $labels | nindent 4 }}
spec:
  refreshInterval: {{ $refreshInterval }}
  secretStoreRef:
    kind: ClusterSecretStore
    name: {{ $storeName }}
  target:
    name: {{ $name }}
    creationPolicy: Owner
  {{- if kindIs "map" $secrets }}
    {{- if $secrets.data }}
  data:
      {{- if eq $type "azure" }}
        {{- range $key, $value := $secrets.data }}
    - secretKey: {{ $key }}
      remoteRef:
        key: {{ $value }}
        {{- end }}
      {{- else }}
        {{- range $secret := $secrets.data }}
    - secretKey: {{ $secret.secretKey }}
      remoteRef:
        {{- if eq $type "gcp" }}
        key: {{ $.Release.Name | upper }}_{{ $secret.secretKey }}
        {{- else if eq $type "vault" }}
        key: {{ $secretPath }}/{{ $.Release.Name }}
        property: {{ $secret.property | default $secret.secretKey }}
        {{- else if eq $type "aws" }}
        key: {{ ternary (print $secretPath "/" $.Release.Name) $.Release.Name (hasKey $.Values.externalSecret "secretPath") }}
        property: {{ $secret.property | default $secret.secretKey }}
        {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if and (hasKey $secrets "dataFrom") (not (empty $secrets.dataFrom)) }}
  dataFrom:
    - extract:
        key: {{ $secretPath }}/{{ $.Release.Name }}
    {{- end }}
  {{- else if kindIs "slice" $secrets }}
  data:
    {{- range $secret := $secrets }}
    - secretKey: {{ $secret }}
      remoteRef:
        key: {{ ternary (print $secretPath "/" $.Release.Name) $.Release.Name (hasKey $.Values.externalSecret "secretPath") }}
        property: {{ $secret }}
    {{- end }}
  {{- end }}
{{- end }}
