{{- if .Values.metrics.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-pushgateway
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.pushgateway.label" . | indent 4 }}
spec:
  type: NodePort
  ports:
    - name: prom-push-exp
      port: 9091 # k8s cluster internal access port
      targetPort: 9091 # container port
      nodePort: {{ .Values.metrics.pushgateway.nodePorts.pushgateway | default 30091 }}
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.pushgateway.label" . | indent 4 }}
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name:  {{ include "linkoopdb.name" . }}-metrics-pushgateway
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.pushgateway.label" . | indent 4 }}
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9091"
spec:
  replicas: 1
  revisionHistoryLimit: 0
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: "25%" #表示滚动升级时会先启动pod个数
      maxUnavailable: "25%" #表示滚动升级时允许的最大Unavailable的pod个数
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.metrics.pushgateway.label" . | indent 8 }}
    spec:
      imagePullSecrets:
        - name: {{ .Values.metrics.pushgateway.image.imagePullSecrets | default .Values.image.imagePullSecrets }}
      containers:
        - name: pushgateway
          image: {{ .Values.metrics.pushgateway.image.repository | default "prom/pushgateway" }}:{{ .Values.metrics.pushgateway.image.tag | default "latest" }}
          imagePullPolicy: {{ .Values.metrics.pushgateway.image.pullPolicy | default .Values.image.pullPolicy }}
          livenessProbe: #kubernetes认为该pod是存活的,不存活则需要重启
            initialDelaySeconds: 600
            periodSeconds: 10
            successThreshold: 1
            failureThreshold: 10
            httpGet:
              path: /
              port: 9091
          resources:
{{ toYaml .Values.metrics.pushgateway.resources | indent 12 }}
{{- end }}