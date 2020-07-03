{{- if .Values.monitor.create }}
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: 'true'
  labels:
    app: node-exporter
    name: node-exporter
  name: node-exporter
  namespace: kube-system
spec:
  clusterIP: None
  ports:
  - name: scrape
    port: 9100
    protocol: TCP
  selector:
    app: node-exporter
  type: ClusterIP

---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: kube-system
  annotations:
    prometheus.io/scrape: "true"
spec:
  template:
    metadata:
      labels:
        app: node-exporter
      name: node-exporter
    spec:
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
      - image: #{linkoopdb.kubernetes.node-exporter.container.image}
        imagePullPolicy: #{linkoopdb.kubernetes.node-exporter.container.image.imagePullPolicy}
        name: node-exporter
        ports:
        - containerPort: 9100
          hostPort: 9100
          name: scrape
      hostNetwork: true
      hostPID: true
{{- end }}