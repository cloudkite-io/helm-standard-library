{{- define "configMapSnippet" -}}
{{- range . }}
{{- if .type.configMap }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .type.configMap.name }}
data:
  {{- range $key, $value := .configMapData }}
  {{ $key }}: | 
    {{ tpl $value $ }}          # <== when this is set to only {{ $value }}, I can see the value/file it wan't to read/get but it prints out an error.
  {{- end }}
{{- end }}
{{- end }}
{{- end }}