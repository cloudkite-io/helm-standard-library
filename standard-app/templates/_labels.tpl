{{- define "standard-app.labels" -}}
{{- $defaultLabels := dict "app" .component "product" .Release.Name -}}
{{- toYaml (merge $defaultLabels (default dict .labels)) | nindent 2 }}
{{- end }}
