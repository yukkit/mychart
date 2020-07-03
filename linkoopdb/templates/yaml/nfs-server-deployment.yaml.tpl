{{- if .Values.nfs.create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
    app.kubernetes.io/component: nfs
spec:
  clusterIP: None
  ports:
  - name: nfs
    port: 2049
    protocol: TCP
  selector:
{{ include "linkoopdb.labels" . | indent 4 }}
    app.kubernetes.io/component: nfs
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ include "linkoopdb.name" . }}-nfs
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
    app.kubernetes.io/component: nfs
spec:
  replicas: 1
  selector:
    matchLabels:
{{ include "linkoopdb.labels" . | indent 6 }}
      app.kubernetes.io/component: nfs
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
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