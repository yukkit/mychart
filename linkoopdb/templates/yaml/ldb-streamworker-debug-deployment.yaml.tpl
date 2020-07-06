{{- if .Values.stream.create }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-stream-debug-worker
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.debugWorker.label" . | indent 4 }}
spec:
  replicas: {{ $.Values.stream.debugWorker.replicas | default 1 }}
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.stream.debugWorker.label" . | indent 6 }}
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.stream.debugWorker.label" . | indent 8 }}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: {{ .Values.stream.nodeAffinity.key }}
                    operator: In
                    values: [{{ .Values.stream.nodeAffinity.values | quote }}]
      hostNetwork: {{ default false .Values.hostNetwork }}
      dnsPolicy: ClusterFirstWithHostNet
      hostPID: {{ default false .Values.hostNetwork }}
      volumes:
        - name: config-vol
          configMap:
            name: {{ include "linkoopdb.name" . }}-database
        - name: stream-config-vol
          configMap:
            name: {{ include "linkoopdb.name" . }}-stream
        - name: yarn-prop-file
          hostPath:
            path: {{ .Values.shareDisk }}/stream/session
            type: DirectoryOrCreate
        {{- if .Values.nfs.create }}
        - name: nfs-client
          persistentVolumeClaim:
            claimName: {{ include "linkoopdb.name" . }}-nfs
        {{- end }}
        {{- if $.Values.hadoop.dependecy }}
        {{- range $key, $value := .Values.hadoop.confPath }}
        - name: hadoop-conf-{{ $key }}
          configMap:
            name: {{ include "linkoopdb.name" $ }}-hadoop-{{ $key }}
        {{- end }}
        {{- end }}
      imagePullSecrets:
        - name: {{ .Values.image.imagePullSecrets }}
      initContainers:
        - name: init
          image: {{ .Values.image.repository}}:{{ .Values.image.tag }}
          command:
            - /bin/bash
            - -c
            - |
              set -ex
              server_cluster={{ include "ldb.database.ha.nodelist" $ | trimAll "," }}
              server_cluster_arr=(${server_cluster//,/ })
              notReady=true
              while ${notReady}; do
                for item in ${server_cluster_arr[@]}; do
                  item_arr=(${item//:/ })
                  server_addr=${item_arr[1]}:{{ $.Values.database.ports.regPort | default 17771 }}
                  [ "$(curl -s ${server_addr}/dbstatus/isready)" == "true" ] && notReady=false
                  [ "${notReady}" == "false" ] && break
                done
                sleep 2s;
              done
      containers:
        - name: worker
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          volumeMounts:
            - name: config-vol
              mountPath: /opt/linkoopdb/conf
            - name: stream-config-vol
              mountPath: /opt/flink/conf/flink-conf.yaml
              subPath: flink-conf.yaml
            - name: yarn-prop-file
              mountPath: /opt/flink-yarn/session
            {{- if .Values.nfs.create }}
            - name: nfs-client
              mountPath: {{ .Values.nfs.mountPath | default "/fsshare"  }}
            {{- end }}
            {{- if .Values.hadoop.dependecy }}
            {{- range $key, $value := .Values.hadoop.confPath }}
            - name: hadoop-conf-{{ $key }}
              mountPath: /etc/hadoop/{{ $key }}
            {{- end }}
            {{- end }}
          args:
            - stream-worker
          ports:
            - containerPort: {{ .Values.stream.streamWorker.ports.workerPort | default 7778 }}
              name: worker-port
          env:
            - name: LINKOOPDB_STREAM_LOCAL_WORK_RUN_MODE
              value: DEBUG
            - name: HADOOP_USER_NAME
              value: {{ .Values.hadoop.user }}
            - name: YARN_CONF_DIR
              value: /etc/hadoop/conf
            - name: LINKOOPDB_STREAM_YARN_KERBEROS_KRB5_CONF
              value: /etc/hadoop/conf/krb5.conf
            - name: LINKOOPDB_STREAM_WORK_DEBUG_WEB_PORT
              value: {{ .Values.stream.streamWorker.ports.workerPort | default 7778 | quote }}
            - name: LINKOOPDB_EXTRA_JDBC_LIB
              value: {{ .Values.nfs.mountPath | default "/fsshare"  }}/{{ .Values.nfs.libPath | default "lib" }}
          resources:
{{ toYaml .Values.stream.streamWorker.resources | indent 12 }}
{{- end }}