{{- if .Values.metrics.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-monitor
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.monitor.label" . | indent 4 }}
spec:
  ports:
    - name: monitor-regport
      port: 9092
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.monitor.label" . | indent 4 }}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-monitor
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.monitor.label" . | indent 4 }}
spec:
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.metrics.monitor.label" . | indent 8 }}
    spec:
      imagePullSecrets:
        - name: {{ .Values.image.imagePullSecrets }}
      containers:
        - name: monitor
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          imagePullPolicy: {{ .Values.image.imagePullSecrets }}
          volumeMounts:
            - name: config
              mountPath: /opt/linkoopdb/conf
            - name: config-vol-tpls
              mountPath: /opt/linkoopdb/conf/tpls
          args:
          - monitor
          env:
          - name: LINKOOPDB_PROMETHEUS_GATEWAY_JOBNAME # Agent Name
            value: ldb-monitor-agent
          - name: LINKOOPDB_PROMETHEUS_GATEWAY_RANDOM_JOBNAME_SUFFIX
            value: {{ .Values.metrics.pushgateway.randomJobnameSuffix | default false | quote }}
          - name: LINKOOPDB_PROMETHEUS_GATEWAY_DELETE_ON_SHUTDOWN
            value: {{ .Values.metrics.pushgateway.deleteOnShutdown | default false | quote }}
          - name: PRETTY_JSON # 存储的服务列表保存格式设置
            value: "true"
          - name: LINKOOPDB_MONITOR_SERVER_PORT #服务启动的端口
            value: "9092"
          resources:
{{ toYaml .Values.metrics.monitor.resources | indent 12 }}
      volumes:
        - name: config
          configMap:
            name: {{ include "linkoopdb.name" $ }}-database
        - name: config-vol-tpls
          configMap:
            name: {{ include "linkoopdb.name" $ }}-tpls
{{- end }}