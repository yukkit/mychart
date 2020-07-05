{{- if .Values.stream.create }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-stream
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.worker.label" . | indent 4 }}
data:
{{ include "stream-configmap.data" . | indent 2 }}
{{- end }}