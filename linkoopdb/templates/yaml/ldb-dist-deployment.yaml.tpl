{{- range .Values.ldbDist }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .domain }}
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/component: ldb-dist-{{ .domain }}
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
spec:
  ports:
  - port: {{ .port }}
  selector:
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/component: ldb-dist-{{ .domain }}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" $ }}-dist-{{ .domain }}
spec:
  selector:
    matchLabels:
        app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
        app.kubernetes.io/instance: {{ $.Release.Name }}
        app.kubernetes.io/component: ldb-dist-{{ .domain }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
        app.kubernetes.io/instance: {{ $.Release.Name }}
        app.kubernetes.io/component: ldb-dist-{{ .domain }}
    spec:
      nodeName: {{ .node }}
      volumes:
      - name: data
        hostPath:
          path: {{ .rootPath }}
          type: DirectoryOrCreate
      imagePullSecrets:
        - name: {{ $.Values.image.imagePullSecrets }}
      containers:
      - name: dist
        image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
        imagePullPolicy: {{ $.Values.image.pullPolicy }}
        args:
        - ldb-dist
        volumeMounts:
        - name: data
          mountPath: /usr/data
        ports:
        - name: dist
          containerPort: {{ .port }}
          hostPort: {{ .port }}
        env:
        - name: LAUNCHER_CONF_FILE_APPEND
          value: "user root;daemon off;"
        - name: LDBDIST_SERVER_FILE_DIR
          value: /usr/data
        - name: LDBDIST_SERVER_PORT
          value: {{ .port | quote }}
        - name: LDBDIST_ROOT_DIR
          value: /usr/data
---
{{- end }}