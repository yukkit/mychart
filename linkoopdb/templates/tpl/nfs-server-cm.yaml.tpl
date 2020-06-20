apiVersion: v1
data:
  # nfs服务相关配置，详情见k8s安装文档或百度
  exports: |-
    /nfsshare *(rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash)
kind: ConfigMap
metadata:
  name: #{linkoopdb.kubernetes.nfs-server.volume.configMap.exports-config.options.name}
  namespace: #{linkoopdb.kubernetes.namespace}