{{- if .Values.studio.create }}
apiVersion: v1
kind: Service
metadata:
  name: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_SERVER_LIST}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  ports:
    - name: web-ui
      nodePort: #{linkoopdb.kubernetes.studio.service.nodePort.web-ui.options.nodePort}
      port: #{linkoopdb.kubernetes.studio.service.nodePort.web-ui.port}
      protocol: TCP
      targetPort: #{linkoopdb.kubernetes.studio.service.nodePort.web-ui.port}
  selector:
    app: ldb
    component: studio
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: ldb
    component: studio
  name: #{linkoopdb.kubernetes.studio.name}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: #{linkoopdb.kubernetes.studio.replicas}
  selector:
    matchLabels:
      app: ldb
      component: studio
  template:
    metadata:
      labels:
        app: ldb
        component: studio
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: #{linkoopdb.kubernetes.studio.nodeAffinity.key}
                    operator: In
                    values: [#{linkoopdb.kubernetes.studio.nodeAffinity.values}]
      volumes:
        - hostPath:
            path: #{linkoopdb.kubernetes.studio.volume.hostPath.logs.options.path}
            type: DirectoryOrCreate
          name: logs
        - hostPath:
            path: #{linkoopdb.kubernetes.studio.volume.hostPath.datasets.options.path}
            type: DirectoryOrCreate
          name: datasets
        - name: init-script
          configMap:
            name: init-script-cm
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
        - image: #{linkoopdb.kubernetes.studio.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.studio.container.image.imagePullPolicy}
          name: ldb-studio
          args:
            - #{linkoopdb.kubernetes.studio.args}
          volumeMounts:
            - mountPath: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_LOGS_DIR}
              name: logs
            - mountPath: /opt/dataset
              name: datasets
          env:
            - name: LINKOOP_DB_JDBC_URL
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_DB_JDBC_URL}
            - name: LINKOOPDB_META_JDBC_URL
              value: #{linkoopdb.kubernetes.studio.env.LINKOOPDB_META_JDBC_URL}
            - name: LINKOOP_STUDIO_META_SOLR_URL
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_META_SOLR_URL}
            - name: SOLR_PORT
              value: "#{linkoopdb.kubernetes.studio.env.SOLR_PORT}"
            - name: LINKOOP_DIST_SERVER_LIST
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_DIST_SERVER_LIST}
            - name: LINKOOP_STUDIO_SERVER_LIST
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_SERVER_LIST}:#{linkoopdb.kubernetes.studio.service.nodePort.web-ui.port}
            - name: LINKOOP_STUDIO_STORAGE_ENGINE
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_STORAGE_ENGINE}
            - name: LINKOOP_STUDIO_SYSTEMTABLE_ENGINE
              value: "#{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_SYSTEMTABLE_ENGINE}"
            - name: LINKOOP_STUDIO_LOGS_DIR
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_LOGS_DIR}
            - name: LINKOOP_DB_NFS_SQL_AUDIT_LOG
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_DB_NFS_SQL_AUDIT_LOG}
            - name: LINKOOP_DB_NFS_FLOW_AUDIT_LOG
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_DB_NFS_FLOW_AUDIT_LOG}
            - name: LINKOOP_DB_NFS_PATH
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_DB_NFS_PATH}
            - name: LINKOOP_STUDIO_META_FILE
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_META_FILE}
            - name: LINKOOP_STUDIO_SERVER_MODE
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_SERVER_MODE}
            - name: JVM_WORKER
              value: "#{linkoopdb.kubernetes.studio.env.JVM_WORKER}"
            - name: LINKOOP_STUDIO_JVM_OPTS
              value: #{linkoopdb.kubernetes.studio.env.LINKOOP_STUDIO_JVM_OPTS}
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.studio.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.studio.cores}"  # 请求cpu，可以认为1000m占用一个cpu
      #          limits:
      #            memory: "#{linkoopdb.kubernetes.studio.limit.memory}"
      #            cpu: "#{linkoopdb.kubernetes.studio.limit.cores}"
      initContainers:
        - name: init
          image: #{linkoopdb.kubernetes.studio.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.studio.container.image.imagePullPolicy}
          volumeMounts:
            - name: init-script
              mountPath: /opt/studio/init
          command:
            - /bin/bash
            - -c
            - |
              set -ex
              $LINKOOPDB_HOME/bin/ldb-client.sh \
              "#{linkoopdb.kubernetes.studio.env.LINKOOPDB_SERVER_JDBC_CLUSTER}" admin 123456 < /opt/studio/init/data-init-default.sql
{{- end }}