{{- if .Values.nfs.create }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "linkoopdb.name" . }}-global
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
    app.kubernetes.io/component: nfs
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: {{ .Values.nfs.storage }}
  storageClassName: nfs
  selector:
    matchLabels:
      {{ .Values.nfs.label.key}}: {{ .Values.nfs.label.value }}
{{- end }}