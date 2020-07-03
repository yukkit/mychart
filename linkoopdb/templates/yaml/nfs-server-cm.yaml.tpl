{{- if .Values.nfs.create }}
apiVersion: v1
data:
  exports: |-
    /nfsshare *(rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash)
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: nfs
    app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}