# my global config
global:
  # 定时更新服务列表时间间隔, 单位毫秒
  discovery_interval: 60000
  # 心跳检查时间间隔, 单位毫秒
  heartbeat_interval: 1000
  # metric上报时间间隔, 单位毫秒
  report_interval: 30000
scrapes:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'linkoopdb-server-0'
    # 服务类型: LINKOOPDB_SERVER, LINKOOPDB_META_SERVER, FLINK_WORKER, SPARK_WORKER, PALLAS_NODE, 默认值是LINKOOPDB_SERVER
    type: 'LINKOOPDB_SERVER'
    target: 'ldb-server-0:17771'
  - job_name: 'linkoopdb-server-1'
    type: 'LINKOOPDB_SERVER'
    target: 'ldb-server-1:17771'
  - job_name: 'linkoopdb-server-2'
    type: 'LINKOOPDB_SERVER'
    target: 'ldb-server-2:17771'
  - job_name: 'meta-server-0'
    type: 'LINKOOPDB_META_SERVER'
    target: 'lmeta-server-0:17772'
  - job_name: 'meta-server-1'
    type: 'LINKOOPDB_META_SERVER'
    target: 'lmeta-server-1:17772'
  - job_name: 'meta-server-2'
    type: 'LINKOOPDB_META_SERVER'
    target: 'lmeta-server-2:17772'