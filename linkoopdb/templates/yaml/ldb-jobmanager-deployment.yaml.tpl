{{- if .Values.stream.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-stream-jobmanager
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 4 }}
spec:
  ports:
    - name: rpc
      port: 6123
    - name: blob
      port: 6124
    - name: query
      port: 6125
    - name: ui
      port: 8081
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 4 }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-stream-jobmanager-ui
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 4 }}
spec:
  type: NodePort
  ports:
    - name: stream-jobmanager-ui
      port: 8081
      targetPort: 8081
      nodePort: {{ .Values.stream.jobmanager.ports.ui | default 30101 }}
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 4 }}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-stream-jobmanager
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 4 }}
spec:
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 6 }}
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.stream.jobmanager.label" . | indent 8 }}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: {{ .Values.stream.nodeAffinity.key }}
                    operator: In
                    values: [{{ .Values.stream.nodeAffinity.values | quote }}]
      volumes:
        - name: stream-config-vol
          configMap:
            name: {{ include "linkoopdb.name" . }}-stream
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
      containers:
        - name: jobmanager
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          imagePullPolicy: {{ .Values.image.imagePullSecrets }}
          volumeMounts:
            - name: stream-config-vol
              mountPath: /opt/flink/conf/flink-conf.yaml
              subPath: flink-conf.yaml
            {{- if .Values.nfs.create }}
            - name: nfs-client
              mountPath: /opt/flink/state/
            - name: nfs-client
              mountPath: /fsshare
            {{- end }}
            {{- if .Values.hadoop.dependecy }}
            {{- range $key, $value := .Values.hadoop.confPath }}
            - name: hadoop-conf-{{ $key }}
              mountPath: /etc/hadoop/{{ $key }}
            {{- end }}
            {{- end }}
          args:
            - flink-job
          env:
            - name: JOB_MANAGER_RPC_ADDRESS
              value: {{ include "linkoopdb.name" . }}-stream-jobmanager
            - name: HADOOP_CLASSPATH
              value: {{ .Values.nfs.mountPath | default "/fsshare"  }}/{{ .Values.nfs.extLibPath | default "extlib" }}
            - name: HADOOP_USER_NAME
              value: {{ .Values.hadoop.user | default "hdfs" }}
            - name: YARN_CONF_DIR
              value: /etc/hadoop/conf
          resources:
{{ toYaml .Values.stream.jobmanager.resources | indent 12 }}
{{- end }}