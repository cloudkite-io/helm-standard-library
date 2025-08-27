{{- define "standard-app.externalSecret" -}}
{{- $apiVersion := .apiVersion }}
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

apiVersion: {{ $apiVersion }}
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
  {{- if and (kindIs "map" $secrets) (hasKey $secrets "dataFrom") }}
  dataFrom:
    {{- range index $secrets "dataFrom" }}
    - extract:
        key: {{ . }}
    {{- end }}
  {{- else }}
  data:
    {{- if eq $type "azure" }}
      {{- range $key, $value := $secrets }}
    - secretKey: {{ $key }}
      remoteRef:
        key: {{ $value }}
      {{- end }}
    {{- else }}
      {{- range $secret := $secrets }}
      {{- if kindIs "map" $secret }}
    - secretKey: {{ if and (eq $type "gcp") $secret.property }}{{ $secret.property }}{{ else }}{{ $secret.secretKey }}{{ end }}
      remoteRef:
        {{- if eq $type "gcp" }}
        key: {{ printf "%s_%s" ($.Release.Name | upper) $secret.secretKey }}
        property: {{ $secret.property | default "" }}
        {{- else if eq $type "vault" }}
        key: {{ printf "%s/%s" $secretPath $.Release.Name }}
        property: {{ $secret.property | default $secret.secretKey }}
        {{- else if eq $type "aws" }}
        key: {{ if $secret.key }}{{ $secret.key }}{{ else }}{{ ternary (print $secretPath "/" $.Release.Name) $.Release.Name (hasKey $.Values.externalSecret "secretPath") }}{{ end }}
        property: {{ $secret.property | default $secret.secretKey }}
        {{- else }}
        key: {{ $secret }}
        property: {{ $secret }}
        {{- end }}
      {{- else }}
    - secretKey: {{ $secret }}
      remoteRef:
        {{- if eq $type "gcp" }}
        key: {{ printf "%s_%s" ($.Release.Name | upper) $secret }}
        {{- else if eq $type "aws" }}
        key: {{ ternary (print $secretPath "/" $.Release.Name) $.Release.Name (hasKey $.Values.externalSecret "secretPath") }}
        property: {{ $secret }}
        {{- else }}
        key: {{ $secret }}
        property: {{ $secret }}
        {{- end }}
      {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
