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

apiVersion: v1
kind: Service
metadata:
  name: prom-pushgateway
  namespace: #{linkoopdb.kubernetes.namespace}
  labels:
    app: prometheus
    component: pushgateway
spec:
  type: NodePort
  ports:
    - name: prom-push-exp
      port: #{linkoopdb.kubernetes.pushgateway.service.nodePort.prom-push-exp.port} # k8s cluster internal access port
      targetPort: #{linkoopdb.kubernetes.pushgateway.service.nodePort.prom-push-exp.port} # container port
      nodePort: #{linkoopdb.kubernetes.pushgateway.service.nodePort.prom-push-exp.options.nodePort}
  selector:
    app: prometheus
    component: pushgateway
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name:  prom-pushgateway
  namespace: #{linkoopdb.kubernetes.namespace}
  labels:
    app:  prometheus
    component: pushgateway
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "#{linkoopdb.kubernetes.pushgateway.service.nodePort.prom-push-exp.port}"
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
      name:  prom-pushgateway
      labels:
        app:  prometheus
        component: pushgateway
    spec:
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
        - name:  prom-pushgateway
          image: #{linkoopdb.kubernetes.pushgateway.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          livenessProbe: #kubernetes认为该pod是存活的,不存活则需要重启
            initialDelaySeconds: 600
            periodSeconds: 10
            successThreshold: 1
            failureThreshold: 10
            httpGet:
              path: /
              port: #{linkoopdb.kubernetes.pushgateway.service.nodePort.prom-push-exp.port}
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.pushgateway.memory}"
              cpu: "#{linkoopdb.kubernetes.pushgateway.cores}"
            limits:
              memory: "#{linkoopdb.kubernetes.pushgateway.limit.memory}"
              cpu: "#{linkoopdb.kubernetes.pushgateway.limit.cores}"