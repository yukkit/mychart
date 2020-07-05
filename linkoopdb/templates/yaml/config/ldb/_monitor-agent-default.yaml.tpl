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
  {{- range $i := until (.Values.server.replicas | default 1 | int) }}
  - job_name: {{ include "linkoopdb.name" $ }}-database-{{ $i }}
    type: 'LINKOOPDB_SERVER'
    target: {{ printf "%s-database-%d.%s-database" (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) }}:{{ $.Values.server.ports.regPort | default 17771 }}
  {{- end }}
  {{- if eq "LINKOOPDB" (.Values.metastore.type | default "LINKOOPDB") }}
  {{- range $i := until (.Values.metastore.replicas | default 1 | int) }}
  - job_name: {{ include "linkoopdb.name" $ }}-metastore-{{ $i }}
    type: 'LINKOOPDB_META_SERVER'
    target: {{ printf "%s-metastore-%d.%s-metastore" (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) }}:17772
  {{- end }}
  {{- end }}
