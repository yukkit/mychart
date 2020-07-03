{{- range $key, $value := .Values.hadoop.confPath }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-hadoop-{{ $key }}
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/component: hadoop
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
    app.kubernetes.io/idx: {{ $key }}
data:
{{ ($.Files.Glob $value).AsConfig | indent 2 }}
---
{{- end }}