{{- if .Values.nfs.create }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include "nfs.pv.name" . }}
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.nfs.label" . | indent 4 }}
spec:
  capacity:
    storage: {{ .Values.nfs.storage | default "100Gi" }}
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: {{ .Values.nfs.reclaimPolicy | default "Delete" }}
  storageClassName: {{ .Release.Name }}-nfs-storage
  nfs:
    path: /
    server: {{ .Values.nfs.node }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.nfs.label" . | indent 4 }}
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: {{ .Values.nfs.storage | default "100Gi" }}
  storageClassName: {{ .Release.Name }}-nfs-storage
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.nfs.label" . | indent 6 }}
{{- end }}