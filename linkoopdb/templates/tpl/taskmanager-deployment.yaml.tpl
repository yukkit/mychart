apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ldb-flink-taskmanager
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: #{linkoopdb.kubernetes.taskmanager.replicas} # to change
  template:
    metadata:
      labels:
        app: ldb-flink
        component: taskmanager
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
            name: #{linkoopdb.kubernetes.stream.volume.configMap.config.options.name} # 需要是个configmap，须预先创建
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
        - name: taskmanager
          image: #{linkoopdb.kubernetes.container.image}
          imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
          volumeMounts:
            - name: config-vol
              mountPath: #{linkoopdb.kubernetes.stream.volume.configMap.config.mount.path}
#{linkoopdb.kubernetes.components.nfs}            - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}              mountPath: #{linkoopdb.kubernetes.stream.volume.nfs.client.options.path}
#{linkoopdb.kubernetes.components.nfs}            - name: nfs-client
#{linkoopdb.kubernetes.components.nfs}              mountPath: #{linkoopdb.kubernetes.server.volume.nfs.client.mount.path}
#{linkoopdb.kubernetes.hadoop.enabled.prefix}            - name: hadoop-conf
#{linkoopdb.kubernetes.hadoop.enabled.prefix}              mountPath: #{linkoopdb.kubernetes.server.volume.configMap.hadoop-conf.mount.path}
          args:
            - flink-task
          # - "-Dtaskmanager.host=$(K8S_POD_IP)"
          ports:
            - containerPort: #{linkoopdb.kubernetes.taskmanager.port.data}
              name: data
            - containerPort: #{linkoopdb.kubernetes.taskmanager.port.rpc}
              name: rpc
            - containerPort: #{linkoopdb.kubernetes.taskmanager.port.query}
              name: query
          env:
            - name: JOB_MANAGER_RPC_ADDRESS
              value: #{linkoopdb.kubernetes.jobmanager.service.clusterIp}
            - name: HADOOP_CLASSPATH  # 借用HADOOP_CLASSPATH，实际是driver的，不用修改flink启动脚本
              value: #{linkoopdb.kubernetes.stream.env.HADOOP_CLASSPATH}
            - name: HADOOP_USER_NAME #HDFS Source和Sink使用的用户名信息
              value: #{linkoopdb.kubernetes.stream.env.HADOOP_USER_NAME}
            - name: YARN_CONF_DIR # hadoop conf dir
              value: #{linkoopdb.kubernetes.stream.env.YARN_CONF_DIR}
            - name: K8S_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          resources:
            requests:
              memory: "#{linkoopdb.kubernetes.taskmanager.memory}"  # 请求内存
              cpu: "#{linkoopdb.kubernetes.taskmanager.cores}"  # 请求cpu，可以认为1000m占用一个cpu
      #          limits:
      #            memory: "#{linkoopdb.kubernetes.taskmanager.limit.memory}"
      #            cpu: "#{linkoopdb.kubernetes.taskmanager.limit.cores}"
