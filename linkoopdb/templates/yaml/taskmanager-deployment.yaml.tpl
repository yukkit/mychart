{{- if .Values.stream.create }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-stream-taskmanager
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.stream.taskmanager.label" . | indent 4 }}
spec:
  replicas: {{ .Values.stream.taskmanager.replicas | default 1 }}
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.stream.taskmanager.label" . | indent 6 }}
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.stream.taskmanager.label" . | indent 8 }}
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
        - name: taskmanager
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
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
            - flink-task
          # - "-Dtaskmanager.host=$(K8S_POD_IP)"
          ports:
            - containerPort: 6121
              name: data
            - containerPort: 6122
              name: rpc
            - containerPort: 6125
              name: query
          env:
            - name: JOB_MANAGER_RPC_ADDRESS
              value: {{ include "linkoopdb.name" . }}-stream-jobmanager
            - name: HADOOP_CLASSPATH
              value: {{ .Values.stream.jobmanager.libPath | default .Values.stream.streamWorker.libPath}}
            - name: HADOOP_USER_NAME
              value: {{ .Values.hadoop.user | default "hdfs" }}
            - name: YARN_CONF_DIR
              value: /etc/hadoop/conf
            - name: K8S_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          resources:
{{ toYaml .Values.stream.taskmanager.resources | indent 12 }}
{{- end }}