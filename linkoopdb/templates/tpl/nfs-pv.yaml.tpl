apiVersion: v1
kind: PersistentVolume
metadata:
  name: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}
  labels:
    pv: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}
spec:
  capacity:
    storage: #{linkoopdb.kubernetes.server.volume.persistentVolume.capacity.storage} # 存储卷的大小
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: #{linkoopdb.kubernetes.server.volume.persistentVolume.persistentVolumeReclaimPolicy}
  storageClassName: nfs
  nfs:
    path: #{linkoopdb.kubernetes.server.volume.nfs.client.options.path}
    server: #{linkoopdb.kubernetes.server.volume.nfs.client.options.server} # nfs服务的ip
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}
  namespace: #{linkoopdb.kubernetes.namespace}
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: #{linkoopdb.kubernetes.server.volume.persistentVolume.capacity.storage} #申请的卷的大小
  storageClassName: nfs
  selector:
    matchLabels:
      pv: #{linkoopdb.kubernetes.server.volume.persistentVolumeClaim.nfs-pv.options.claimName}

