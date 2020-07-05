apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-tpls
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.tpls.label" . | indent 4 }}
data:
{{ include "tpls-configmap.data" . | indent 2 }}

