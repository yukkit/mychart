apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-database
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: database
    app.kubernetes.io/managed-by: {{ .Release.Service }}
data:
{{ include "ldb-configmap.data" . | indent 2 }}

