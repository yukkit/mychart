apiVersion: v1
kind: Service
metadata:
  name: #{linkoopdb.kubernetes.jobmanager.service.clusterIp}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  ports:
    - name: rpc
      port: #{linkoopdb.kubernetes.jobmanager.service.clusterIp.rpc.port}
    - name: blob
      port: #{linkoopdb.kubernetes.jobmanager.service.clusterIp.blob.port}
    - name: query
      port: #{linkoopdb.kubernetes.jobmanager.service.clusterIp.query.port}
    - name: ui
      port: #{linkoopdb.kubernetes.jobmanager.service.nodePort.flink-ui.port}
  selector:
    app: ldb-flink
    component: jobmanager
---
apiVersion: v1
kind: Service
metadata:
  name: ldb-flink-nodeport
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  type: NodePort
  ports:
    - name: flink-ui
      port: #{linkoopdb.kubernetes.jobmanager.service.nodePort.flink-ui.port} # k8s cluster internal access port
      targetPort: #{linkoopdb.kubernetes.jobmanager.service.nodePort.flink-ui.port}  # container port
      nodePort: #{linkoopdb.kubernetes.jobmanager.service.nodePort.flink-ui.options.nodePort}  # extra can assess port
  selector:
    app: ldb-flink
    component: jobmanager
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ldb-flink-jobmanager
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: 1 # not change
  template:
    metadata:
      labels:
        app: ldb-flink
        component: jobmanager
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: #{linkoopdb.kubernetes.stream.nodeAffinity.key}
                    operator: In
                    values: [#{linkoopdb.kubernetes.stream.nodeAffinity.values}]
      volumes:
        - name: config-vol
          configMap:
            name: #{linkoopdb.kubernetes.jobmanager.volume.configMap.config.options.name} # 需要是个configmap，须预先创建
#{linkoopdb.kubernetes.components.nfs}        - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}          persistentVolumeClaim:
#{linkoopdb.kubernetes.components.nfs}            claimName: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}
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
        - name: jobmanager
          image: #{linkoopdb.kubernetes.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          volumeMounts:
            - name: config-vol
              mountPath: #{linkoopdb.kubernetes.stream.volume.configMap.config.mount.path}
#{linkoopdb.kubernetes.components.nfs}            - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}              mountPath: #{linkoopdb.kubernetes.stream.volume.nfs.client.options.path}
#{linkoopdb.kubernetes.components.nfs}            - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}              mountPath: #{linkoopdb.kubernetes.server.volume.nfs.client.mount.path}
            - name: share
              mountPath: #{linkoopdb.kubernetes.server.volume.empty.share.mount.path}
          args:
            - flink-job
          env:
            - name: JOB_MANAGER_RPC_ADDRESS
              value: #{linkoopdb.kubernetes.jobmanager.service.clusterIp}
            - name: HADOOP_CLASSPATH # 借用HADOOP_CLASSPATH，实际是driver的，不用修改flink启动脚本
              value: #{linkoopdb.kubernetes.stream.env.HADOOP_CLASSPATH}
            - name: HADOOP_USER_NAME #HDFS Source和Sink使用的用户名信息
              value: #{linkoopdb.kubernetes.stream.env.HADOOP_USER_NAME}
            - name: YARN_CONF_DIR # hadoop conf dir
              value: #{linkoopdb.kubernetes.stream.env.YARN_CONF_DIR}
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.jobmanager.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.jobmanager.cores}"  # 请求cpu，可以认为1000m占用一个cpu
#          limits:
#            memory: "#{linkoopdb.kubernetes.jobmanager.limit.memory}"
#            cpu: "#{linkoopdb.kubernetes.jobmanager.limit.cores}"
