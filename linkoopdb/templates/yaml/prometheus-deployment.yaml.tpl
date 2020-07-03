{{- if .Values.monitor.create }}
################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
# 简单处理，直接使用 NodePort 暴露服务，你也可以使用 Ingress
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: #{linkoopdb.kubernetes.namespace}
  labels:
    app:  prometheus
    component: server
spec:
  selector:
    app: prometheus
    component: server
  ports:
    - name: prometheus-port
      protocol: TCP
      port: #{linkoopdb.kubernetes.prometheus.service.nodePort.prometheus-port.port}
      nodePort: #{linkoopdb.kubernetes.prometheus.service.nodePort.prometheus-port.options.nodePort}
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: prometheus-deployment
  namespace: #{linkoopdb.kubernetes.namespace}
  labels:
    app:  prometheus
    component: server
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: prometheus
        component: server
    spec:
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
      - name: prometheus
        image: #{linkoopdb.kubernetes.prometheus.container.image}
        args:
        - '--config.file=/opt/prometheus-data/prometheus.yml'
#        ports:
#        - name: prometheus
#          containerPort: 9090
        volumeMounts:
        - name: data-volume
          mountPath: #{linkoopdb.kubernetes.prometheus.volume.configMap.data-volume.mount.path}
        resources:
          requests:
            cpu: "#{linkoopdb.kubernetes.prometheus.cores}"
            memory: "#{linkoopdb.kubernetes.prometheus.memory}"
          limits:
            cpu: "#{linkoopdb.kubernetes.prometheus.limit.cores}"
            memory: "#{linkoopdb.kubernetes.prometheus.limit.memory}"
      serviceAccountName: prometheus
      volumes:
      - name: data-volume
        configMap:
          name: #{linkoopdb.kubernetes.prometheus.volume.configMap.data-volume.options.name}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: #{linkoopdb.kubernetes.namespace}
  labels:
    app: prometheus
data:
  prometheus.yml: |
    # my global config
    global:
      scrape_interval:     5s
      evaluation_interval: 5s
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
        - targets: ['localhost:#{linkoopdb.kubernetes.prometheus.service.nodePort.prometheus-port.port}']

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
          - targets: ['prom-pushgateway:#{linkoopdb.kubernetes.pushgateway.service.nodePort.prom-push-exp.port}']
{{- end }}