apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: 'true'
  name: nfs-server
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  clusterIP: None
  ports:
  - name: nfs
    port: #{linkoopdb.kubernetes.nfs-server.service.headless.nfs.port}
    protocol: TCP
  selector:
    app: nfs
    component: server
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nfs-server
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  replicas: 1 # not change
  template:
    metadata:
      labels:
        app: nfs
        component: server
    spec:
      nodeName: #{linkoopdb.kubernetes.nfs-server.nodeName} # nfs启动在node8上
      volumes:
      - name: nfs # nfs挂载的物理盘,可配置多个
        hostPath:
          path: #{linkoopdb.kubernetes.nfs-server.volume.hostPath.nfs.options.path}
          type: DirectoryOrCreate
      - name: exports-config
        configMap:
          name: #{linkoopdb.kubernetes.nfs-server.volume.configMap.exports-config.options.name}
      hostNetwork: true
      hostPID: true
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
      - name: nfs-srver
        image: #{linkoopdb.kubernetes.container.image} # 镜像
        imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
        securityContext:
          privileged: true
        args:
        - nfs-server
        ports:
        - containerPort: #{linkoopdb.kubernetes.nfs-server.service.headless.nfs.port}
          name: nfs-port
        volumeMounts:
        - name: nfs # 物理盘挂载到容器内的目录，要一一对应不能多个盘挂同一个目录
          mountPath: #{linkoopdb.kubernetes.nfs-server.volume.hostPath.nfs.mount.path}
        - name: exports-config
          mountPath: #{linkoopdb.kubernetes.nfs-server.volume.configMap.exports-config.mount.path}
          subPath: #{linkoopdb.kubernetes.nfs-server.volume.configMap.exports-config.mount.subPath}

