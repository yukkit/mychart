{{- if .Values.nfs.create }}
apiVersion: v1
data:
  exports: |-
    /nfsshare *(rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash)
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
    app.kubernetes.io/component: nfs
{{- end }}