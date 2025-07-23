{{/*
Render a container spec given a container name and config,
falling back to app-level and global values as needed.
Supports env, envFrom, volumes, probes, resources, securityContext, etc.

Usage:
  {{- include "standard-app.container" (dict "name" $containerName "container" $containerConfig "app" $appConfig "appName" $appName "global" $.Values) | nindent 6 }}

Required dict keys:
- name        : string - container name
- container   : dict - container-specific config
- app         : dict - app-level config
- appName     : string - app name for secrets etc
- global      : dict - global values for fallback

*/}}
{{- define "standard-app.container" -}}
{{- $name := .name -}}
{{- $container := .container | default dict -}}
{{- $app := .app | default dict -}}
{{- $appName := .appName -}}
{{- $global := .global | default dict -}}
- name: {{ $name }}
  image: "{{ ($container.image | default $app.image | default $global.image) }}:{{ ($container.tag | default $app.tag | default $global.tag) }}"
  imagePullPolicy: "{{ ($container.imagePullPolicy | default $app.imagePullPolicy | default $global.imagePullPolicy) }}"
  {{- if $container.command }}
  command:
    {{- range $container.command }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if $container.args }}
  args:
    {{- range $container.args }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if or $container.ports $app.ports }}
  ports:
    {{- if $container.ports -}}
      {{ toYaml $container.ports | nindent 4 }}
    {{- else }}
      {{ toYaml $app.ports | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or $container.readinessProbe $app.readinessProbe }}
  readinessProbe:
    {{- with (or $container.readinessProbe $app.readinessProbe) -}}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or $container.livenessProbe $app.livenessProbe }}
  livenessProbe:
    {{- with (or $container.livenessProbe $app.livenessProbe) -}}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  env:
    {{- $mergedEnv := merge (default dict $global.env) (default dict $app.env) (default dict $container.env) }}
    {{- range $key, $value := $mergedEnv }}
    - name: {{ $key }}
      value: {{ $value | quote }}
    {{- end }}
  envFrom:
    {{- if or $container.secrets $app.secrets $global.secrets }}
      {{- if $container.secrets }}
    - secretRef:
        name: {{ $name }}
      {{- end }}
      {{- if and (not $container.secrets) $app.secrets }}
    - secretRef:
        name: {{ $appName }}
      {{- end }}
      {{- if and (not $container.secrets) (not $app.secrets) $global.secrets }}
    - secretRef:
        name: {{ $global.release.Name }}
      {{- end }}
    {{- end }}
  {{- if or $container.resources $app.resources }}
  resources:
    {{- with (or $container.resources $app.resources) -}}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or $container.volumes $app.volumes }}
  volumeMounts:
    {{- $volumes := $container.volumes | default $app.volumes }}
    {{- range $volumes }}
    - mountPath: {{ .mountPath }}
      name: {{ .name }}
      {{- if .subPath }}
      subPath: {{ .subPath }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if $container.securityContext }}
  securityContext:
    {{ toYaml $container.securityContext | nindent 4 }}
  {{- end }}
{{- end }}
