apiVersion: v1
kind: Service
metadata:
  name: #{linkoopdb.kubernetes.dbserver.service.headless}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  ports:
    - port: #{linkoopdb.kubernetes.dbserver.ports.jdbc.containerPort}
      name: jdbc
    - port: #{linkoopdb.kubernetes.dbserver.service.headless.reg.port}
      name: reg
    - port: #{linkoopdb.kubernetes.dbserver.service.headless.atomix.port}
      name: atomix
  selector:
    app: ldb
    component: server
    idx: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: #{linkoopdb.kubernetes.dbserver.name}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: #{linkoopdb.kubernetes.dbserver.replicas}
  template:
    metadata:
      labels:
        app: ldb
        component: server
        idx: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: #{linkoopdb.kubernetes.dbserver.nodeAffinity.key}
                    operator: In
                    values: [#{linkoopdb.kubernetes.dbserver.nodeAffinity.values}]
              - matchExpressions:
                  - key: kubernetes.io/hostname
                    operator: In
                    values: [#{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}]
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - ldb
                  - key: component
                    operator: In
                    values:
                      - server
      hostNetwork: #{linkoopdb.kubernetes.hostNetwork}
      dnsPolicy: ClusterFirstWithHostNet
      hostPID: #{linkoopdb.kubernetes.hostPID}
      terminationGracePeriodSeconds: 60
      volumes:
        - name: config
          configMap:
            name: #{linkoopdb.kubernetes.server.volume.configMap.config.options.name}
        - name: spark-conf
          configMap:
            name: #{linkoopdb.kubernetes.server.volume.configMap.spark-conf.options.name}
#{linkoopdb.kubernetes.components.nfs}        - name: client
#{linkoopdb.kubernetes.components.nfs}          persistentVolumeClaim:
#{linkoopdb.kubernetes.components.nfs}            claimName: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}
        - name: tlogs # 全局事务日志
          hostPath:
            path: #{linkoopdb.kubernetes.server.volume.hostPath.tlogs.options.path}
            type: DirectoryOrCreate
        - name: logs # 日志盘路径
          hostPath:
            path: #{linkoopdb.kubernetes.server.volume.hostPath.logs.options.path}
            type: DirectoryOrCreate
#{linkoopdb.kubernetes.hadoop.enabled.prefix}        - name: hadoop-conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}          secret:
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            secretName: #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.options.name}
        - name: share
          emptyDir: {}
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      initContainers:
        - name: init
          image: #{linkoopdb.kubernetes.container.image}
          volumeMounts:
            - name: share
              mountPath: #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - name: hadoop-conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}
          command:
            - /bin/bash
            - -c
            - |
              set -ex
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}ls -l #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}for hadoop_conf in `ls #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}`; do
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}  if [ ! -d #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}/$hadoop_conf ]; then
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}    mkdir #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}/$hadoop_conf
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}    tar -zxvf #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}/$hadoop_conf -C #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}/$hadoop_conf
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}  fi
              #{linkoopdb.kubernetes.hadoop.enabled.prefix}done

              server_cluster=#{linkoopdb.kubernetes.dbserver.env.LINKOOPMETA_REG_CLUSTER}
              server_cluster_arr=(${server_cluster//,/ })

              notReady=true
              while ${notReady}; do
                for server_addr in ${server_cluster_arr[@]}; do
                  [ "$(curl -s ${server_addr}/dbstatus/isready)" == "true" ] && notReady=false
                  [ "${notReady}" == "false" ] && break
                done
                sleep 2s;
              done
      containers:
        - name: ldb-server
          image: #{linkoopdb.kubernetes.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          volumeMounts:
            - name: config
              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.config.mount.path}
            - name: spark-conf
              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.spark-conf.mount.path}
#{linkoopdb.kubernetes.components.nfs}            - name: client
#{linkoopdb.kubernetes.components.nfs}              mountPath: #{linkoopdb.kubernetes.server.volume.nfs.client.mount.path} # nfs挂载到容器内的目录
            - name: tlogs
              mountPath: /opt/linkoopdb/ldb-server/ldb-server # nfs挂载到容器内的目录
            - name: logs # 日志盘挂载到容器内的路径
              mountPath: #{linkoopdb.kubernetes.server.volume.hostPath.logs.mount.path}
            - name: share
              mountPath: #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}
          args:
            - server
            - #{linkoopdb.kubernetes.dbserver.args}
          lifecycle:
            preStop:
              exec:
                command:
                  - /bin/bash
                  - -c
                  - |
                    /usr/bin/kill `jps|grep LinkoopDBServer|awk '{print $1}'`;
                    worker_pid=`jps|grep SparkSubmit|awk '{print $1}'`;
                    until [ "$worker_pid" == "" ]; do
                    worker_pid=`jps|grep SparkSubmit|awk '{print $1}'`;
                    echo "sleep 2";
                    sleep 2;
                    done
          ports:
            - name: jdbc
              containerPort: #{linkoopdb.kubernetes.dbserver.ports.jdbc.containerPort}
              hostPort: #{linkoopdb.kubernetes.dbserver.ports.jdbc.hostPort}
            - name: sync
              containerPort: #{linkoopdb.kubernetes.dbserver.ports.sync.containerPort}
              hostPort: #{linkoopdb.kubernetes.dbserver.ports.sync.hostPort}
          env:
            - name: SERVERMODE
              value: #{linkoopdb.kubernetes.dbserver.env.SERVERMODE}
            - name: LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID
              value: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID}
            - name: LDB_LNS_HOST
              value: #{linkoopdb.kubernetes.server.env.LDB_LNS_HOST}
            - name: LDB_LNS_PORT
              value: "#{linkoopdb.kubernetes.server.env.LDB_LNS_PORT}"
            - name: LINKOOP_FEATURE # ldb\istream\all
              value: "#{linkoopdb.kubernetes.dbserver.env.LINKOOP_FEATURE}"
            - name: WORKERLAUNCHER # local, spark need register to server
              value: #{linkoopdb.kubernetes.dbserver.env.WORKERLAUNCHER}
            - name: LINKOOPDB_STORAGE_LAUNCHER
              value: #{linkoopdb.kubernetes.server.env.LINKOOPDB_STORAGE_LAUNCHER}
            - name: LINKOOPDB_BASE # data dir，need nfs location. hdfs-host is a external service, with same namespace
              value: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_BASE}
            - name: HADOOP_USER_NAME # hdfs user
              value: #{linkoopdb.kubernetes.dbserver.env.HADOOP_USER_NAME}
            - name: YARN_CONF_DIR # hadoop conf dir
              value: #{linkoopdb.kubernetes.server.env.YARN_CONF_DIR}
            - name: LINKOOPDB_STREAM_RESOURCE_GROUP_STARTUP_MODE
              value: single
            - name: BATCH_WORKER_JARS_IN_HDFS # worker metric reporter host
              value: #{linkoopdb.kubernetes.dbserver.env.BATCH_WORKER_JARS_IN_HDFS}
            - name: LINKOOPDB_STREAM_LOCAL_WORK_RUN_MODE #yarn rest debug
              value: #{linkoopdb.kubernetes.streamworker.env.WORK_RUN_MODE}
            - name: LINKOOPDB_META_JDBC_URL
              # metastore jdbc uri. ha mode eg. jdbc:linkoopdb:cluster://lmeta-server-0.meta:9105|lmeta-server-1.meta:9106|lmeta-server-2.meta:9107/ldb
              value: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_META_JDBC_URL}
            - name: SPARK_METRICS_REPORTER_GATEWAY_HOST # worker metric reporter host
              value: #{linkoopdb.kubernetes.dbserver.env.METRICS_REPORTER_GATEWAY_HOST}
            - name: SPARK_METRICS_REPORTER_GATEWAY_PORT # worker metric reporter port, default 9091
              value: "#{linkoopdb.kubernetes.dbserver.env.METRICS_REPORTER_GATEWAY_PORT}"
            - name: SPARK_METRICS_REPORTER_GATEWAY_JOB_NAME # # worker metric reporter job name
              value: #{linkoopdb.kubernetes.dbserver.env.METRICS_REPORTER_GATEWAY_JOB_NAME}
            - name: LINKOOPDB_LOGS_DIR # log dir
              value: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_LOGS_DIR}
            - name: EXTRA_LIBS # spark use
              value: #{linkoopdb.kubernetes.dbserver.env.EXTRA_LIBS}
            - name: ALL_EXTRA_CLASSPATH # server use
              value: #{linkoopdb.kubernetes.dbserver.env.ALL_EXTRA_CLASSPATH}
            - name: LINKOOPDB_JVM_OPTS
              value: #{linkoopdb.kubernetes.dbserver.env.LINKOOPDB_JVM_OPTS}
            - name: EXTERNAL_K8S_PORT
              value: "#{linkoopdb.kubernetes.dbserver.env.EXTERNAL_K8S_PORT}"
            - name: NODE_ORDER_LIST
              value: "#{linkoopdb.kubernetes.dbserver.env.NODE_ORDER_LIST}"
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
              memory: "#{linkoopdb.kubernetes.dbserver.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.dbserver.cores}"  # 请求cpu，可以认为1000m占用一个cpu
#          limits:
#            memory: "#{linkoopdb.kubernetes.dbserver.limit.memory}"
#            cpu: "#{linkoopdb.kubernetes.dbserver.limit.cores}"


