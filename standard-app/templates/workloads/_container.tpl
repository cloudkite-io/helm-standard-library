{{/*
Render a container spec given a container name and config,
falling back to app-level and global values as needed.
Supports env, envFrom, volumes, probes, resources, securityContext, etc.

Usage:
  {{- include "standard-app.container" (dict "name" $containerName "container" $containerConfig "app" $appConfig "appName" $appName "global" $.Values "releaseName" $.Release.Name) | nindent 6 }}

Required dict keys:
- name            : string - container name
- container       : dict - container-specific config
- app             : dict - app-level config
- appName         : string - app name for secrets etc
- global          : dict - global values for fallback
- releaseName     : string - chart release name

Optional dict keys:
- isInitContainer : boolean - check true if init container

*/}}
{{- define "standard-app.container" -}}
{{- $name := .name -}}
{{- $app := .app | default dict -}}
{{- $appName := .appName -}}
{{- $releaseName := .releaseName -}}
{{- $global := .global | default dict -}}
{{- $isInitContainer := .isInitContainer | default false -}}
{{- $effectiveGlobalSecretName := $releaseName -}}
{{- if and (hasKey .global "externalSecret") (hasKey .global.externalSecret "secretName") -}}
  {{- $effectiveGlobalSecretName = .global.externalSecret.secretName -}}
{{- end -}}

- name: {{ $name }}
  image: "{{ (.container.image | default $app.image | default $global.image) }}:{{ (.container.tag | default $app.tag | default $global.tag) }}"
  imagePullPolicy: "{{ (.container.imagePullPolicy | default $app.imagePullPolicy | default $global.imagePullPolicy) }}"
  {{- if or (hasKey .container "command") (hasKey $app "command") }}
  command:
    {{- range or (index .container "command") (index $app "command") }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if or (hasKey .container "args") (hasKey $app "args") }}
  args:
    {{- range or (index .container "args") (index $app "args") }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if not .isInitContainer }}
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
  {{- if or (hasKey .container "startupProbe") (hasKey $app "startupProbe") }}
  startupProbe:
    {{- with or (index .container "startupProbe") (index $app "startupProbe") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- end }}
  env:
    {{- $mergedEnv := mergeOverwrite (dict) (default dict (index $global "env")) (default dict (index $app "env")) (default dict (index .container "env")) }}
    {{- range $key, $value := $mergedEnv }}
    - name: {{ $key }}
      value: {{ $value | quote }}
    {{- end }}
    {{- with (index $app "otherenv") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with (index $global "otherenv") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  envFrom:
    {{- if hasKey .container "otherenvFrom" }}
      {{- toYaml (index .container "otherenvFrom") | nindent 4 }}
    {{- end }}
    {{- with (index $app "otherenvFrom") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with (index $global "otherenvFrom") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if hasKey .container "secrets" }}
    - secretRef:
        name: {{ $name }}
    {{- end }}
    {{- if not (and (hasKey .container "omitParentSecrets") .container.omitParentSecrets) }}
    {{- if hasKey $app "secrets" }}
    - secretRef:
        name: {{ $appName }}
    {{- end }}
    {{- if hasKey $global "secrets" }}
    - secretRef:
        name: {{ $effectiveGlobalSecretName }}
    {{- end }}
    {{- end }}
  {{- if or (hasKey .container "resources") (hasKey $app "resources") }}
  resources:
    {{- with or (index .container "resources") (index $app "resources") }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if or (hasKey .container "lifecycle") (hasKey $app "lifecycle") }}
  lifecycle:
    {{- with or (index .container "lifecycle") (index $app "lifecycle") }}
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
      {{- if hasKey . "readOnly" }}
      readOnly: {{ index . "readOnly" }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if hasKey .container "securityContext" }}
  securityContext:
    {{- toYaml (index .container "securityContext") | nindent 4 }}
  {{- else if hasKey $app "securityContext" }}
  securityContext:
    {{- toYaml (index $app "securityContext") | nindent 4 }}
  {{- end }}
{{- end }}
