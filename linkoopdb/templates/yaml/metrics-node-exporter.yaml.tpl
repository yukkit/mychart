{{- if .Values.metrics.create }}
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: 'true'
  name: {{ include "linkoopdb.name" . }}-metrics-exporter
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.exporter.label" . | indent 4 }}
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  - name: scrape
    port: 9100
    protocol: TCP
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.exporter.label" . | indent 4 }}
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-exporter
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.exporter.label" . | indent 4 }}
  annotations:
    prometheus.io/scrape: "true"
spec:
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.metrics.exporter.label" . | indent 8 }}
      name: {{ include "linkoopdb.name" . }}-metrics-exporter
    spec:
      imagePullSecrets:
        - name: {{ .Values.metrics.exporter.image.imagePullSecrets | default .Values.image.imagePullSecrets }}
      containers:
      - image: {{ .Values.metrics.exporter.image.repository }}:{{ .Values.metrics.exporter.image.tag | default "latest" }}
        imagePullPolicy: {{ .Values.metrics.exporter.image.pullPolicy | default .Values.image.pullPolicy }}
        name: node-exporter
        ports:
        - containerPort: 9100
          hostPort: 9100
          name: scrape
      hostNetwork: true
      hostPID: true
{{- end }}