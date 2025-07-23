{{- define "standard-app.configMap" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .name }}
data:
  {{- range $key, $value := .data }}
  {{ $key }}: |-
    {{ $value | nindent 4 }}
  {{- end }}
{{- end }}