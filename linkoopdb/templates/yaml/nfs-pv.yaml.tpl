{{- if .Values.nfs.create }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "linkoopdb.name" . }}-global
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: all
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