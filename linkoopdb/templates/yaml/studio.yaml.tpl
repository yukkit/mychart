{{- if .Values.studio.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-studio
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.studio.label" . | indent 4 }}
spec:
  type: NodePort
  ports:
    - name: web-ui
      nodePort: 30510
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.studio.label" . | indent 4 }}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-studio
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.studio.label" . | indent 4 }}
spec:
  replicas: 1
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
{{ include "linkoopdb.studio.label" . | indent 6 }}
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.studio.label" . | indent 8 }}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: {{ $.Values.studio.nodeAffinity.key }}
                    operator: In
                    values: [{{ $.Values.studio.nodeAffinity.value | quote }}]
      volumes:
        - hostPath:
            path: {{ .Values.shareDisk | default "/tmp/linkoopdb" }}/logs/studio
            type: DirectoryOrCreate
          name: logs
        - hostPath:
            path: {{ .Values.shareDisk | default "/tmp/linkoopdb" }}/studio/dataset
            type: DirectoryOrCreate
          name: datasets
        - name: init-script
          configMap:
            name: init-script-cm
      imagePullSecrets:
        - name: {{ .Values.studio.image.imagePullSecrets | default .Values.image.imagePullSecrets }}
      containers:
        - name: studio
          image: {{ .Values.studio.image.repository | default "prom/pushgateway" }}:{{ .Values.studio.image.tag | default "latest" }}
          imagePullPolicy: {{ .Values.studio.image.pullPolicy | default .Values.image.pullPolicy }}
          args:
            - studio
          volumeMounts:
            - mountPath: opt/studio/slogs
              name: logs
            - mountPath: /opt/dataset
              name: datasets
          env:
            - name: LINKOOP_DB_JDBC_URL
            {{- if eq "single" (include "database.mode" .) }}
              value: {{ include "linkoopdb.name" . }}-database-0.{{ include "linkoopdb.name" . }}-database
            {{- else }}
              value: {{ include "ldb.database.uris" . }}
            {{- end }}
            - name: LINKOOP_STUDIO_META_SOLR_URL
              value: http://localhost:8987/solr
            - name: SOLR_PORT
              value: "8987"
            - name: LINKOOP_DIST_SERVER_LIST
              value: {{ "" }}
            - name: LINKOOP_STUDIO_SERVER_LIST
              value: {{ include "linkoopdb.name" . }}-studio:8080
            - name: LINKOOP_STUDIO_STORAGE_ENGINE
              value: PALLAS
            - name: LINKOOP_STUDIO_SYSTEMTABLE_ENGINE
              value: "true"
            - name: LINKOOP_STUDIO_LOGS_DIR
              value: /opt/studio/slogs
            - name: LINKOOP_DB_NFS_SQL_AUDIT_LOG
              value: /tmp
            - name: LINKOOP_DB_NFS_FLOW_AUDIT_LOG
              value: /tmp
            - name: LINKOOP_DB_NFS_PATH
              value: /tmp
            - name: LINKOOP_STUDIO_META_FILE
              value: /tmp
            - name: LINKOOP_STUDIO_SERVER_MODE
              value: single
            - name: JVM_WORKER
              value: "64"
            - name: LINKOOP_STUDIO_JVM_OPTS
              value:
          resources:
{{ toYaml .Values.studio.resources | indent 12 }}
      initContainers:
        - name: init
          image: {{ .Values.studio.image.repository | default "prom/pushgateway" }}:{{ .Values.studio.image.tag | default "latest" }}
          imagePullPolicy: {{ .Values.studio.image.pullPolicy | default .Values.image.pullPolicy }}
          volumeMounts:
            - name: init-script
              mountPath: /opt/studio/init
          command:
            - /bin/bash
            - -c
            - |
              set -ex
              $LINKOOPDB_HOME/bin/ldb-client.sh \
              {{- if eq "single" (include "database.mode" .) }}
              {{ include "linkoopdb.name" . }}-database-0.{{ include "linkoopdb.name" . }}-database \
              {{- else }}
              {{ include "ldb.database.uris" . }} \
              {{- end }}
              admin 123456 < /opt/studio/init/data-init-default.sql
{{- end }}