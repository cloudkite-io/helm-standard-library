{{- define "standard-app.labels" -}}
{{- $defaultLabels := dict "app" .component "product" .Release.Name -}}
labels:
{{- toYaml (merge $defaultLabels (default dict .labels)) | nindent 2 }}
{{- end }}
