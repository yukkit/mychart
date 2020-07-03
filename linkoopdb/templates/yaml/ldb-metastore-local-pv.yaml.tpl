{{- if eq .Values.metastore.type "LINKOOPDB" }}
{{- range $node := (regexSplit "\\s+" (include "metastore.nodes" $ ) -1) }}
{{- $pv_name := printf "%s-%s" (include "metastore.pv.prefix" $) $node }}
{{- $pv := (lookup "v1" "PersistentVolume" "" $pv_name) }}
{{- if empty $pv }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include "metastore.pv.prefix" $ }}-{{ $node }}
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/component: metastore
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: {{ include "metastore.pv.prefix" $ }}-local-storage
  local:
    path: {{ $.Values.shareDisk }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - {{ $node }}
---
{{- end }}
{{- end }}
{{- end }}