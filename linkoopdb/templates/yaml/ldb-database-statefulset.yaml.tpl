apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" $ }}-database
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.database.label" . | indent 4 }}
spec:
  ports:
    - port: {{ default 9105 $.Values.database.ports.jdbcPort }}
      name: jdbc
    - port: {{ default 17771 $.Values.database.ports.regPort }}
      name: reg
    - port: {{ default 5001 $.Values.database.ports.atomixPort }}
      name: atomix
  clusterIP: None
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.database.label" . | indent 4 }}
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: {{ include "linkoopdb.name" $ }}-database
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.database.label" . | indent 4 }}
spec:
  replicas: {{ $.Values.database.replicas | default 1 | int }}
  serviceName: {{ include "linkoopdb.name" $ }}-database
  podManagementPolicy: Parallel
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.database.label" . | indent 6 }}
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.database.label" . | indent 8 }}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: {{ $.Values.database.nodeAffinity.key }}
                    operator: In
                    values: [{{ $.Values.database.nodeAffinity.value | quote }}]
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchExpressions:
                  - key: app.kubernetes.io/instance
                    operator: In
                    values:
                      - {{ $.Release.Name }}
                  - key: app.kubernetes.io/component
                    operator: In
                    values:
                      - server
      hostNetwork: {{ default false $.Values.hostNetwork }}
      dnsPolicy: ClusterFirstWithHostNet
      hostPID: {{ default false $.Values.hostNetwork }}
      terminationGracePeriodSeconds: 60
      volumes:
        - name: config
          configMap:
            name: {{ include "linkoopdb.name" $ }}-database
        - name: worker-conf
          configMap:
            name: {{ include "linkoopdb.name" $ }}-batch
        {{- if $.Values.nfs.create }}
        - name: client
          persistentVolumeClaim:
            claimName: {{ include "linkoopdb.name" $ }}-nfs
        {{- end }}
        {{- if $.Values.hadoop.dependecy }}
        {{- range $key, $value := $.Values.hadoop.confPath }}
        - name: hadoop-conf-{{ $key }}
          configMap:
            name: {{ include "linkoopdb.name" $ }}-hadoop-{{ $key }}
        {{- end }}
        {{- end }}
      imagePullSecrets:
        - name: {{ $.Values.image.imagePullSecrets }}
{{- if eq "LINKOOPDB" ($.Values.metastore.type | default "LINKOOPDB") }}
      initContainers:
        - name: init
          image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
          imagePullPolicy: {{ $.Values.image.pullPolicy }}
          command:
            - /bin/bash
            - -c
            - |
              set -ex
              server_cluster={{ include "ldb.metastore.ha.nodelist" $ | trimAll "," }}
              server_cluster_arr=(${server_cluster//,/ })

              notReady=true
              while ${notReady}; do
                for item in ${server_cluster_arr[@]}; do
                  item_arr=(${item//:/ })
                  server_addr=${item_arr[1]}:17772
                  [ "$(curl -s ${server_addr}/dbstatus/isready)" == "true" ] && notReady=false
                  [ "${notReady}" == "false" ] && break
                done
                sleep 2s;
              done
{{- end }}
      containers:
        - name: server
          image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
          imagePullPolicy: {{ $.Values.image.pullPolicy }}
          volumeMounts:
            - name: config
              mountPath: /opt/linkoopdb/conf
            - name: worker-conf
              mountPath: /opt/spark/conf
            {{- if $.Values.nfs.create }}
            - name: client
              mountPath: {{ $.Values.nfs.mountPath | default "/fsshare"  }}
            {{- end }}
            - name: {{ include "database.pv.prefix" $ }}-local-pv
              mountPath: /opt/linkoopdb/ldb-server/ldb-server
            - name: {{ include "database.pv.prefix" $ }}-local-pv
              mountPath: /opt/logs
            {{- if $.Values.hadoop.dependecy }}
            {{- range $key, $value := $.Values.hadoop.confPath }}
            - name: hadoop-conf-{{ $key }}
              mountPath: /etc/hadoop/{{ $key }}
            {{- end }}
            {{- end }}
          args:
            - server
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
              containerPort: {{ default 9105 $.Values.database.ports.jdbcPort }}
              hostPort: {{ default 9105 $.Values.database.ports.jdbcPort }}
            - name: sync
              containerPort: {{ default 33041 $.Values.database.ports.syncPort }}
              hostPort: {{ default 33041 $.Values.database.ports.syncPort }}
          env:
            - name: LDB_LNS_TYPE
              value: {{ $.Values.license.type | default "datapps" }}
            - name: LDB_LNS_HOST
              value: {{ $.Values.license.host }}
            - name: LDB_LNS_PORT
              value: {{ $.Values.license.port | default 7700 | quote}}
            - name: HADOOP_USER_NAME # hdfs user
              value: {{ $.Values.hadoop.user }}
            - name: YARN_CONF_DIR # hadoop conf dir
              value: /etc/hadoop/conf
            - name: LINKOOPDB_LOGS_DIR # log dir
              value: /opt/logs
            - name: EXTRA_LIBS # spark use
              value: {{ $.Values.nfs.mountPath | default "/fsshare"  }}/{{ $.Values.nfs.libPath | default "lib" }}
            - name: ALL_EXTRA_CLASSPATH # server use
              value: {{ $.Values.nfs.mountPath | default "/fsshare"  }}/{{ $.Values.nfs.libPath | default "lib" }}/*:{{ $.Values.nfs.mountPath | default "/fsshare"  }}/{{ $.Values.nfs.extLibPath | default "extlib" }}/*
            - name: LINKOOPDB_JVM_OPTS
              value: {{ $.Values.database.config.jvmOpts }}
            - name: EXTERNAL_K8S_PORT
              value: {{ $.Values.database.ports.jdbcPort | default 9105 | quote }}
            - name: LINKOOPDB_CLUSTER_LOCALMEMBER_NODEID
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
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
{{ toYaml $.Values.database.resources | indent 12 }}
  volumeClaimTemplates:
  - metadata:
      name: {{ include "database.pv.prefix" $ }}-local-pv
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
      storageClassName: {{ include "database.pv.prefix" $ }}-local-storage
      volumeMode: Filesystem
