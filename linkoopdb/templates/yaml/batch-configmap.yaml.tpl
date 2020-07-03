apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-batch
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.batch.label" . | indent 4 }}
data:
{{ include "batch-configmap.data" . | indent 2 }}

