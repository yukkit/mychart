{{- if eq .Values.metastore.type "LINKOOPDB" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" $ }}-metastore
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metastore.label" . | indent 4 }}
spec:
  ports:
    - port: 9106
      name: jdbc
    - port: 17772
      name: reg
    - port: 5002
      name: atomix
  clusterIP: None
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metastore.label" . | indent 4 }}
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: {{ include "linkoopdb.name" $ }}-metastore
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.metastore.label" . | indent 4 }}
spec:
  replicas: {{ default 1 $.Values.metastore.replicas }}
  serviceName: {{ include "linkoopdb.name" $ }}-metastore
  podManagementPolicy: Parallel
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.metastore.label" . | indent 6 }}
  template:
    metadata:
      labels:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.metastore.label" . | indent 8 }}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: {{ $.Values.metastore.nodeAffinity.key }}
                    operator: In
                    values: [{{ $.Values.metastore.nodeAffinity.value | quote }}]
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
                      - metastore
      hostNetwork: false
      dnsPolicy: ClusterFirstWithHostNet
      hostPID: false
      terminationGracePeriodSeconds: 60
      volumes:
        - name: config-vol
          configMap:
            name: {{ include "linkoopdb.name" $ }}-database
        - name: spark-conf
          configMap:
            name: {{ include "linkoopdb.name" $ }}-batch
      imagePullSecrets:
        - name: {{ $.Values.image.imagePullSecrets }}
      containers:
        - image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
          imagePullPolicy: {{ $.Values.image.pullPolicy }}
          name: metastore
          volumeMounts:
            - name: config-vol
              mountPath: /opt/linkoopdb/conf
            - name: spark-conf
              mountPath: /opt/spark/conf
            - name: {{ include "metastore.pv.prefix" $ }}-local-pv
              mountPath: /opt/logs
            - name: {{ include "metastore.pv.prefix" $ }}-local-pv
              mountPath: /opt/linkoopdb/ldb-meta-server/ldb-server
          args:
            - meta-server
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
            - name: LINKOOPDB_LOGS_DIR
              value: /opt/logs
            - name: LINKOOPDB_META_JVM_OPTS
              value: "{{ $.Values.metastore.config.jvmOpts }} {{ include "ldb.metastore.extraJvmOpts" $ }}"
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
{{ toYaml $.Values.metastore.resources | indent 12 }}
  volumeClaimTemplates:
  - metadata:
      name: {{ include "metastore.pv.prefix" $ }}-local-pv
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
      storageClassName: {{ include "metastore.pv.prefix" $ }}-local-storage
      volumeMode: Filesystem
{{- end }}