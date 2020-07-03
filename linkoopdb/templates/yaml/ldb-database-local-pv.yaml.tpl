{{- range $node := (regexSplit "\\s+" (include "database.nodes" $ ) -1) }}
{{- $pv_name := printf "%s-%s" (include "database.pv.prefix" $) $node }}
{{- $pv := (lookup "v1" "PersistentVolume" "" $pv_name) }}
{{- if empty $pv }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include "database.pv.prefix" $ }}-{{ $node }}
  labels:
{{ include "linkoopdb.labels" $ | indent 4 }}
{{ include "linkoopdb.database.label" $ | indent 4 }}
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: {{ include "database.pv.prefix" $ }}-local-storage
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
