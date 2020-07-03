{{- if .Values.stream.create }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" $ }}-stream
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: stream
    app.kubernetes.io/managed-by: {{ .Release.Service }}
data:
{{ include "stream-configmap.data" . | indent 2 }}
{{- end }}