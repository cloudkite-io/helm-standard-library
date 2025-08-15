{{- define "standard-app.spotNodeSelection.nodeAffinity" -}}
{{- if eq .Values.preferSpot "aks" }}
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 60
      preference:
        matchExpressions:
          - key: 'kubernetes.azure.com/scalesetpriority'
            operator: In
            values:
              - 'spot'
    - weight: 10
      preference:
        matchExpressions:
          - key: 'kubernetes/nodetype'
            operator: In
            values:
              - 'regular'
{{- end -}}
{{- end -}}

{{- define "standard-app.spotNodeSelection.toleration" -}}
{{- if eq .Values.preferSpot "aks" }}
- key: kubernetes.azure.com/scalesetpriority
  operator: Equal
  value: spot
  effect: NoSchedule
{{- end -}}
{{- end -}}
