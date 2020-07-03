apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-database
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.database.label" . | indent 4 }}
data:
{{ include "ldb-configmap.data" . | indent 2 }}

