{{- range $key, $value := .Values.hadoop.confPath }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-hadoop-{{ $key }}
  labels:
{{ include "linkoopdb.labels" $ | indent 4 }}
{{ include "linkoopdb.hadoop.label" $ | indent 4 }}
    app.kubernetes.io/idx: {{ $key }}
data:
{{ ($.Files.Glob $value).AsConfig | indent 2 }}
---
{{- end }}