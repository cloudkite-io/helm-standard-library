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
{{- $app := .app | default dict -}}
{{- $appName := .appName -}}
{{- $global := .global | default dict -}}
- name: {{ $name }}
  image: "{{ (.container.image | default $app.image | default $global.image) }}:{{ (.container.tag | default $app.tag | default $global.tag) }}"
  imagePullPolicy: "{{ (.container.imagePullPolicy | default $app.imagePullPolicy | default $global.imagePullPolicy) }}"
  {{- if hasKey .container "command" }}
  command:
    {{- range index .container "command" }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if hasKey .container "args" }}
  args:
    {{- range index .container "args" }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if or (hasKey .container "ports") (hasKey $app "ports") }}
  ports:
    {{- if hasKey .container "ports" }}
      {{- toYaml (index .container "ports") | nindent 4 }}
    {{- else }}
      {{- toYaml (index $app "ports") | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or (hasKey .container "readinessProbe") (hasKey $app "readinessProbe") }}
  readinessProbe:
    {{- with or (index .container "readinessProbe") (index $app "readinessProbe") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or (hasKey .container "livenessProbe") (hasKey $app "livenessProbe") }}
  livenessProbe:
    {{- with or (index .container "livenessProbe") (index $app "livenessProbe") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  env:
    {{- $mergedEnv := merge (default dict (index $global "env")) (default dict (index $app "env")) (default dict (index .container "env")) }}
    {{- range $key, $value := $mergedEnv }}
    - name: {{ $key }}
      value: {{ $value | quote }}
    {{- end }}
  envFrom:
    {{- if hasKey .container "secrets" }}
    - secretRef:
        name: {{ $name }}
    {{- end }}
    {{- if hasKey $app "secrets" }}
    - secretRef:
        name: {{ $appName }}
    {{- end }}
    {{- if and (hasKey $global "secrets") (gt (len $global.secrets) 0) }}
    - secretRef:
        name: {{ .releaseName }}
    {{- end }}
  {{- if or (hasKey .container "resources") (hasKey $app "resources") }}
  resources:
    {{- with or (index .container "resources") (index $app "resources") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or (hasKey .container "volumes") (hasKey $app "volumes") }}
  volumeMounts:
    {{- $volumes := (hasKey .container "volumes" | ternary (index .container "volumes") (index $app "volumes")) }}
    {{- range $volumes }}
    - mountPath: {{ .mountPath }}
      name: {{ .name }}
      {{- if hasKey . "subPath" }}
      subPath: {{ index . "subPath" }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if hasKey .container "securityContext" }}
  securityContext:
    {{- toYaml (index .container "securityContext") | nindent 4 }}
  {{- end }}
{{- end }}
