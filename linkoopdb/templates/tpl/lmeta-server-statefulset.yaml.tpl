apiVersion: v1
kind: Service
metadata:
  name: #{linkoopdb.kubernetes.metaserver.service.headless}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  ports:
    - port: #{linkoopdb.kubernetes.metaserver.service.headless.reg.port}
      name: reg
    - port: #{linkoopdb.kubernetes.metaserver.service.headless.atomix.port}
      name: atomix
    - name: jdbc
      port: #{linkoopdb.kubernetes.metaserver.service.headless.jdbc.port}
  selector:
    app: lmeta
    component: server
    idx: #{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: #{linkoopdb.kubernetes.metaserver.name}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: #{linkoopdb.kubernetes.metaserver.replicas}
  template:
    metadata:
      labels:
        app: lmeta
        component: server
        idx: #{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: #{linkoopdb.kubernetes.metaserver.nodeAffinity.key}
                    operator: In
                    values: [#{linkoopdb.kubernetes.metaserver.nodeAffinity.values}]
              - matchExpressions:
                  - key: kubernetes.io/hostname
                    operator: In
                    values: [#{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}]
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - lmeta
                  - key: component
                    operator: In
                    values:
                      - server
      hostNetwork: #{linkoopdb.kubernetes.hostNetwork}
      dnsPolicy: ClusterFirstWithHostNet
      hostPID: #{linkoopdb.kubernetes.hostPID}
      terminationGracePeriodSeconds: 60
      volumes:
        - name: config-vol
          configMap:
            name: #{linkoopdb.kubernetes.server.volume.configMap.config.options.name} # 需要是个configmap，须预先创建
        - name: spark-conf
          configMap:
            name: #{linkoopdb.kubernetes.server.volume.configMap.spark-conf.options.name}
        - name: logs # 日志盘路径
          hostPath:
            path: #{linkoopdb.kubernetes.server.volume.hostPath.logs.options.path}
            type: DirectoryOrCreate
        - name: tlogs
          hostPath:
            path: #{linkoopdb.kubernetes.server.volume.hostPath.tlogs.options.path}
            type: DirectoryOrCreate
#{linkoopdb.kubernetes.hadoop.enabled.prefix}        - name: hadoop-conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}          secret:
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            secretName: #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.options.name}
        - name: share
          emptyDir: {}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}      initContainers:
#{linkoopdb.kubernetes.hadoop.enabled.prefix}        - name: init
#{linkoopdb.kubernetes.hadoop.enabled.prefix}          image: #{linkoopdb.kubernetes.container.image}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}          volumeMounts:
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - name: share
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              mountPath: #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - name: hadoop-conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}          command:
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - /bin/bash
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - -c
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - |
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              set -ex
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              ls -l #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              for hadoop_conf in `ls #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}`; do
#{linkoopdb.kubernetes.hadoop.enabled.prefix}                if [ ! -d #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}/$hadoop_conf ]; then
#{linkoopdb.kubernetes.hadoop.enabled.prefix}                  mkdir #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}/$hadoop_conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}                  tar -zxvf #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}/$hadoop_conf -C #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}/$hadoop_conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}                fi
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              done
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
        - image: #{linkoopdb.kubernetes.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          name: ldb-srver
          volumeMounts:
            - name: config-vol
              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.config.mount.path}
            - name: spark-conf
              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.spark-conf.mount.path}
            - name: logs # 日志盘挂载到容器内的路径
              mountPath: #{linkoopdb.kubernetes.server.volume.hostPath.logs.mount.path}
            - name: tlogs
              mountPath: /opt/linkoopdb/ldb-meta-server/ldb-server # nfs挂载到容器内的目录
            - name: share
              mountPath: #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}
          args:
            - meta-server
            - #{linkoopdb.kubernetes.metaserver.args}
          lifecycle:
            preStop:
              exec:
                command:
                  - /bin/bash
                  - -c
                  - |
                    /usr/bin/kill `jps|grep LinkoopMetaServer|awk '{print $1}'`;
                    worker_pid=`jps|grep SparkSubmit|awk '{print $1}'`;
                    until [ "$worker_pid" == "" ]; do
                    worker_pid=`jps|grep SparkSubmit|awk '{print $1}'`;
                    echo "sleep 2";
                    sleep 2;
                    done
          env:
            - name: SERVERMODE
              value: #{linkoopdb.kubernetes.metaserver.env.SERVERMODE}
            - name: LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID
              value: #{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}
            - name: LINKOOP_FEATURE # ldb\istream\all
              value: "#{linkoopdb.kubernetes.metaserver.env.LINKOOP_FEATURE}"
            - name: WORKERLAUNCHER # local, spark need register to server
              value: #{linkoopdb.kubernetes.metaserver.env.WORKERLAUNCHER}
            - name: LINKOOPDB_STORAGE_LAUNCHER
              value: #{linkoopdb.kubernetes.server.env.LINKOOPDB_STORAGE_LAUNCHER}
            - name: LINKOOPDB_BASE # data dir，need nfs location. hdfs-host is a external service, with same namespace
              value: #{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_BASE}
            - name: HADOOP_USER_NAME # hdfs user
              value: #{linkoopdb.kubernetes.metaserver.env.HADOOP_USER_NAME}
            - name: YARN_CONF_DIR # hadoop conf dir
              value: #{linkoopdb.kubernetes.server.env.YARN_CONF_DIR}
            - name: BATCH_WORKER_JARS_IN_HDFS # worker metric reporter host
              value: #{linkoopdb.kubernetes.metaserver.env.BATCH_WORKER_JARS_IN_HDFS}
            - name: LINKOOPDB_LOGS_DIR # log dir
              value: #{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_LOGS_DIR}
            - name: LINKOOPDB_JVM_OPTS
              value: #{linkoopdb.kubernetes.metaserver.env.LINKOOPDB_JVM_OPTS}
            - name: NODE_ORDER_LIST
              value: "#{linkoopdb.kubernetes.metaserver.env.NODE_ORDER_LIST}"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: HOST_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.metaserver.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.metaserver.cores}"  # 请求cpu，可以认为1000m占用一个cpu
#          limits:
#            memory: "#{linkoopdb.kubernetes.metaserver.limit.memory}"
#            cpu: "#{linkoopdb.kubernetes.metaserver.limit.cores}"


