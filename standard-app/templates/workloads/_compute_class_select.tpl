{{- define "standard-app.generalComputeClass.nodeSelector" -}}
{{- if eq .Values.generalComputeClass "on" }}
cloud.google.com/compute-class: general-compute-class
{{- end -}}
{{- end -}}
