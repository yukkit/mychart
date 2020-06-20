apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: #{linkoopdb.stream.worker.name}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: 1 # not change
  template:
    metadata:
      labels:
        app: ldb
        component: flink-worker
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: #{linkoopdb.kubernetes.stream.nodeAffinity.key}
                    operator: In
                    values: [#{linkoopdb.kubernetes.stream.nodeAffinity.values}]
      hostNetwork: #{linkoopdb.kubernetes.hostNetwork}
      dnsPolicy: ClusterFirstWithHostNet
      hostPID: #{linkoopdb.kubernetes.hostPID}
      volumes:
        - name: config-vol
          configMap:
            name: #{linkoopdb.kubernetes.server.volume.configMap.config.options.name} # 需要是个configmap，须预先创建
        - name: flink-config-vol
          configMap:
            name: #{linkoopdb.kubernetes.stream.volume.configMap.config.options.name} # 需要是个configmap，须预先创建
        - name: yarn-prop-file
          hostPath:
            path: #{linkoopdb.kubernetes.streamworker.volume.hostPath.session.options.path}
            type: DirectoryOrCreate
#{linkoopdb.kubernetes.components.nfs}        - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}          persistentVolumeClaim:
#{linkoopdb.kubernetes.components.nfs}            claimName: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}
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

              server_cluster=#{linkoopdb.kubernetes.streamworker.env.LINKOOPDB_REG_CLUSTER}
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
        - name: ldb-flink-worker
          image: #{linkoopdb.kubernetes.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          volumeMounts:
            - name: config-vol
              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.config.mount.path}
            - name: flink-config-vol
              mountPath: #{linkoopdb.kubernetes.stream.volume.configMap.config.mount.path}
            - name: yarn-prop-file # yarn properties file 挂载到容器内的路径
              mountPath: #{linkoopdb.kubernetes.streamworker.volume.hostPath.session.mount.path}
#{linkoopdb.kubernetes.components.nfs}            - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}              mountPath: #{linkoopdb.kubernetes.server.volume.nfs.client.mount.path}
            - name: share
              mountPath: #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}
          args:
            - stream-worker # only flink-worker
            - #{linkoopdb.kubernetes.streamworker.args}
          ports:
            - containerPort: #{linkoopdb.kubernetes.streamworker.port.worker-port}
              name: worker-port
          env:
            - name: SERVERMODE
              value: #{linkoopdb.kubernetes.streamworker.env.SERVERMODE}
            - name: LINKOOPDB_SERVER_REGISTER_HOST # server host, ldb-server is a service name.
              value: ldb-server-0
            - name: LINKOOPDB_SERVER_REGISTER_PORT # server reg port
              value: "#{linkoopdb.kubernetes.dbserver.service.headless.reg.port}"
            - name: LINKOOPDB_STREAM_LOCAL_WORK_PORT # worker port
              value: "#{linkoopdb.kubernetes.streamworker.port.worker-port}"
            - name: LINKOOPDB_SERVER_CLUSTER # ha 模式
              value: #{linkoopdb.kubernetes.streamworker.env.LINKOOPDB_SERVER_CLUSTER}
            - name: LINKOOPDB_STREAM_LOCAL_WORK_RUN_MODE #yarn rest debug
              value: #{linkoopdb.kubernetes.streamworker.env.WORK_RUN_MODE}
            - name: LINKOOPDB_STREAM_WORK_REST_WEB_UI # rest web url
              value: #{linkoopdb.kubernetes.streamworker.env.WORK_WEB_UI}
            - name: HADOOP_USER_NAME # hdfs user
              value: #{linkoopdb.kubernetes.stream.env.HADOOP_USER_NAME}
            - name: YARN_CONF_DIR # hadoop conf dir
              value: #{linkoopdb.kubernetes.stream.env.YARN_CONF_DIR}
            - name: LINKOOPDB_STREAM_YARN_KERBEROS_KRB5_CONF
              value: #{linkoopdb.kubernetes.streamworker.env.LINKOOPDB_STREAM_YARN_KERBEROS_KRB5_CONF}
            - name: LINKOOPDB_STREAM_WORK_DEBUG_WEB_PORT
              value: "#{linkoopdb.kubernetes.streamworker.env.LINKOOPDB_STREAM_WORK_DEBUG_WEB_PORT}"
            - name: LINKOOPDB_EXTRA_JDBC_LIB
              value: #{linkoopdb.kubernetes.streamworker.env.EXTRA_LIBS}
          #- name: LINKOOPDB_STREAM_WORKER_JVM_OPTS # jvm
          #  value: -Xmx1g -Xss256k
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.streamworker.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.streamworker.cores}"  # 请求cpu，可以认为1000m占用一个cpu
#          limits:
#            memory: "#{linkoopdb.kubernetes.streamworker.limit.memory}"
#            cpu: "#{linkoopdb.kubernetes.streamworker.limit.cores}"

