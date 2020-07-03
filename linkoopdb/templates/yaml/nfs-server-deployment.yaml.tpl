{{- if .Values.nfs.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: nfs
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  clusterIP: None
  ports:
  - name: nfs
    port: 2049
    protocol: TCP
  selector:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: nfs
    app.kubernetes.io/managed-by: {{ .Release.Service }}
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: nfs
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  replicas: 1
  selector:
    matchLabels:
        app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        app.kubernetes.io/component: nfs
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        app.kubernetes.io/component: nfs
    spec:
      nodeName: {{ .Values.nfs.node }}
      volumes:
      - name: nfs
        hostPath:
          path: {{ .Values.nfs.path }}
          type: DirectoryOrCreate
      - name: exports-config
        configMap:
          name: {{ include "linkoopdb.name" . }}-nfs
      hostNetwork: true
      hostPID: true
      imagePullSecrets:
        - name: {{ .Values.image.imagePullSecrets }}
      containers:
      - name: nfs
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        securityContext:
          privileged: true
        args:
        - nfs-server
        ports:
        - containerPort: 2049
          name: nfs-port
        volumeMounts:
        - name: nfs
          mountPath: /nfsshare
        - name: exports-config
          mountPath: /etc/exports
          subPath: exports
{{- end }}