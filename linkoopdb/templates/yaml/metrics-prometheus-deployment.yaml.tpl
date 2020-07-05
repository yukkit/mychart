{{- if .Values.metrics.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-prometheus
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.prometheus.label" . | indent 4 }}
spec:
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.prometheus.label" . | indent 4 }}
  ports:
    - name: prometheus
      protocol: TCP
      port: 9090
      nodePort: {{.Values.metrics.prometheus.nodePorts.prometheus | default 30090 }}
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-prometheus
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.prometheus.label" . | indent 4 }}
spec:
  replicas: 1
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.metrics.prometheus.label" . | indent 8 }}
    spec:
      imagePullSecrets:
        - name: {{ .Values.metrics.prometheus.image.imagePullSecrets | default .Values.image.imagePullSecrets }}
      serviceAccountName: prometheus
      volumes:
      - name: data-volume
        configMap:
          name: {{ include "linkoopdb.name" . }}-metrics-prometheus
      containers:
      - name: prometheus
        image: {{ .Values.metrics.prometheus.image.repository | default "prom/prometheus" }}:{{ .Values.metrics.prometheus.image.tag | default "latest" }}
        imagePullPolicy: {{ .Values.metrics.prometheus.image.pullPolicy | default .Values.image.pullPolicy }}
        args:
        - '--config.file=/opt/prometheus-data/prometheus.yml'
        volumeMounts:
        - name: data-volume
          mountPath: /opt/prometheus-data
        resources:
{{ toYaml .Values.metrics.pushgateway.resources | indent 10 }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "linkoopdb.name" . }}-metrics-prometheus
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metrics.prometheus.label" . | indent 4 }}
data:
  prometheus.yml: |
    # my global config
    global:
      scrape_interval:     5s
      evaluation_interval: 5s
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
        - targets: ['localhost:9090']

      - job_name: 'kubernetes-apiservers'
        scrape_interval: 1m
        scrape_timeout: 10s
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https

      - job_name: pushgateway
        honor_labels: true
        static_configs:
          - targets: ['{{ include "linkoopdb.name" . }}-metrics-pushgateway:9091']
{{- range $node := (lookup "v1" "Node" "" "").items }}
      - job_name: {{ $node.metadata.name }}
        static_configs:
        - targets: ['{{ $node.metadata.name }}:9100']
{{- end }}
{{- end }}