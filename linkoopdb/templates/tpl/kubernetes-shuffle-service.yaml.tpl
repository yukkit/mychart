apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    app: spark-shuffle-service
    spark-version: 2.4.0
  name: shuffle
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  template:
    metadata:
      labels:
        app: spark-shuffle-service
        spark-version: 2.4.0
    spec:
      volumes:
      - name: temp-volume
        hostPath:
          path: '/tmp/spark-local'
          type: DirectoryOrCreate
      imagePullSecrets:
        - name: #{linkoopdb.kubernetes.container.image.imagePullSecrets}
      containers:
      - name: shuffle
        image: #{linkoopdb.kubernetes.container.image}
        imagePullPolicy: #{linkoopdb.kubernetes.container.image.pullPolicy}
        volumeMounts:
        - name: temp-volume
          mountPath: '/tmp/spark-local'
        args:
        - external-shuffle-service
        resources:
          requests:
            memory: "#{linkoopdb.kubernetes.spark-shuffle-service.memory}"  # 请求内存
            cpu: "#{linkoopdb.kubernetes.spark-shuffle-service.cores}"  # 请求cpu，可以认为1000m占用一个cpu
#          limits:
#            memory: "#{linkoopdb.kubernetes.spark-shuffle-service.limit.memory}"
#            cpu: "#{linkoopdb.kubernetes.spark-shuffle-service.limit.cores}"
