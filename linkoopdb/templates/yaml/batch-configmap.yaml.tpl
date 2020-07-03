apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-batch
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: batch
    app.kubernetes.io/managed-by: {{ .Release.Service }}
data:
{{ include "batch-configmap.data" . | indent 2 }}

