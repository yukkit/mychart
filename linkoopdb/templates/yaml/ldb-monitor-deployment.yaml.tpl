{{- if .Values.monitor.create }}
apiVersion: v1
kind: Service
metadata:
  name: #{linkoopdb.kubernetes.monitor.service.clusterIp}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  ports:
    - name: monitor-regport
      port: #{linkoopdb.kubernetes.monitor.service.clusterIp.monitor-regport.port}
  selector:
    app: ldb
    component: monitor
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ldb-monitor
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: 1 # not change
  template:
    metadata:
      labels:
        app: ldb
        component: monitor
    spec:
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
        - name: ldb-monitor
          image: #{linkoopdb.kubernetes.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          volumeMounts:
            - name: config
              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.config.mount.path}
            - name: config-vol-tpls
              mountPath: #{linkoopdb.kubernetes.monitor.volume.configMap.config-vol-tpls.mount.path}
          args:
          - monitor # only monitor
#          ports:
#          - containerPort: 9092
#            name: monitor-reg
          env:
          - name: METRICS_REPORTER_GATEWAY_HOST # Prometheus PushGateway IP
            value: #{linkoopdb.kubernetes.monitor.env.METRICS_REPORTER_GATEWAY_HOST}
          - name: METRICS_REPORTER_GATEWAY_PORT # Prometheus PushGateway PORT
            value: "#{linkoopdb.kubernetes.monitor.env.METRICS_REPORTER_GATEWAY_PORT}"
          - name: LINKOOPDB_PROMETHEUS_GATEWAY_JOBNAME # Agent Name
            value: #{linkoopdb.kubernetes.monitor.env.LINKOOPDB_PROMETHEUS_GATEWAY_JOBNAME}
          - name: LINKOOPDB_PROMETHEUS_GATEWAY_RANDOM_JOBNAME_SUFFIX #用默认值
            value: "#{linkoopdb.kubernetes.monitor.env.LINKOOPDB_PROMETHEUS_GATEWAY_RANDOM_JOBNAME_SUFFIX}"
          - name: LINKOOPDB_PROMETHEUS_GATEWAY_DELETE_ON_SHUTDOWN # hdfs user
            value: "#{linkoopdb.kubernetes.monitor.env.LINKOOPDB_PROMETHEUS_GATEWAY_DELETE_ON_SHUTDOWN}"
          - name: PRETTY_JSON # 存储的服务列表保存格式设置
            value: "#{linkoopdb.kubernetes.monitor.env.PRETTY_JSON}"
          - name: LINKOOPDB_MONITOR_SERVER_PORT #服务启动的端口
            value: "#{linkoopdb.kubernetes.monitor.env.LINKOOPDB_MONITOR_SERVER_PORT}"
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.monitor.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.monitor.cores}"  # 请求cpu，可以认为1000m占用一个cpu
            limits:
              memory: "#{linkoopdb.kubernetes.monitor.limit.memory}"
              cpu: "#{linkoopdb.kubernetes.monitor.limit.cores}"
          #- name: LINKOOPDB_JVM_OPTS
          #  value: -Xmx1g -Xss256k
      volumes:
        - name: config
          configMap:
            name: #{linkoopdb.kubernetes.server.volume.configMap.config.options.name} # 需要是个configmap，须预先创建
        - name: config-vol-tpls
          configMap:
            name: #{linkoopdb.kubernetes.monitor.volume.configMap.config-vol-tpls.options.name} # 需要是个configmap，须预先创建
{{- end }}