apiVersion: v1
kind: Service
metadata:
  name: #{linkoopdb.kubernetes.ldbdist}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  ports:
  - port: 54321
  selector:
    app: ldb
    component: dist
    id: #{linkoopdb.kubernetes.ldbdist}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: #{linkoopdb.kubernetes.ldbdist}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ldb
        component: dist
        id: #{linkoopdb.kubernetes.ldbdist}
    spec:
      nodeName: #{linkoopdb.kubernetes.ldbdist.nodeName}
      volumes:
      - name: data
        hostPath:
          path: #{linkoopdb.kubernetes.ldbdist.volume.hostPath.data.options.path}
          type: DirectoryOrCreate
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
      - name: dist
        image: #{linkoopdb.kubernetes.container.image}
        imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
        args:
        - ldb-dist
        volumeMounts:
        - name: data
          mountPath: /usr/data
        ports:
        - name: dist
          containerPort: 54321
          hostPort: 54321
        env:
        - name: LAUNCHER_CONF_FILE_APPEND
          value: "user root;daemon off;"
        - name: LDBDIST_SERVER_FILE_DIR
          value: /usr/data
        - name: LDBDIST_SERVER_PORT
          value: "54321"
        - name: LDBDIST_ROOT_DIR
          value: /usr/data

