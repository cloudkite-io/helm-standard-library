{{/*
 Generate config map data
 */}}
{{- define "standard-app.configData" -}}
{{- if .Values.configMap }}
{{- range $key, $value := .Values.configMap }}
{{ $key }}: |
  {{ $value | nindent 4 }}
{{- end }}
{{- end }}

{{- range $appName, $appConfig := .Values.apps -}}
{{- if $appConfig.volumes }}
{{- range $appConfig.volumes }}
{{- if .type.configMap }}
{{ $appName }}-{{ .name }}-volumeConfigMap: |
{{- range $key, $value := .configMapData }}
{{ $key }}: | 
  {{ $value | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- range $cronjobName, $cronjobConfig := .Values.cronjobs -}}
{{- if $cronjobConfig.volumes }}
{{- range $cronjobConfig.volumes }}
{{- if .type.configMap }}
{{ $cronjobName }}-{{ .name }}-volumeConfigMap: |
{{- range $key, $value := .configMapData }}
{{ $key }}: | 
  {{ $value | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
 Generate secrets data
 */}}
{{- define "standard-app.secretsData" -}}
{{- end -}}
