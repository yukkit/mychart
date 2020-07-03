{{- if .Values.stream.create }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-stream-worker
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: stream-worker
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: stream-worker
      app.kubernetes.io/managed-by: {{ .Release.Service }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        app.kubernetes.io/component: stream-worker
        app.kubernetes.io/managed-by: {{ .Release.Service }}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: {{ .Values.stream.nodeAffinity.key }}
                    operator: In
                    values: [{{ .Values.stream.nodeAffinity.values }}]
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
            claimName: {{ .Values.nfs.label.value }}
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
                  server_addr=${item_arr[1]}:{{ $.Values.server.ports.regPort }}
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
              mountPath: {{ .Values.nfs.mountPath }}
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
            - containerPort: {{ .Values.stream.streamWorker.ports.workerPort }}
              name: worker-port
          env:
            - name: HADOOP_USER_NAME
              value: {{ .Values.hadoop.user }}
            - name: YARN_CONF_DIR
              value: /etc/hadoop/conf
            - name: LINKOOPDB_STREAM_YARN_KERBEROS_KRB5_CONF
              value: /etc/hadoop/conf/krb5.conf
            - name: LINKOOPDB_STREAM_WORK_DEBUG_WEB_PORT
              value: "#{linkoopdb.kubernetes.streamworker.env.LINKOOPDB_STREAM_WORK_DEBUG_WEB_PORT}"
            - name: LINKOOPDB_EXTRA_JDBC_LIB
              value: {{ .Values.stream.streamWorker.libPath}}
          resources:
{{ toYaml .Values.stream.streamWorker.resources | indent 12 }}
{{- end }}