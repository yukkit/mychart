#
# '#'开头的行是注释。
# 如果参数中有中文，那么本配置文件格式必须是utf8(没有BOM)。
#
{
  # for recovery
  #"recover_from" : "/path/to/xxxxx.backupkv",
  #"recover_by_move" : false,

  "master": {
    # 当servermode为ha的时候，需要设置servercluster
    "servermode": "ha",
    "servercluster": "127.0.0.1:8888,127.0.0.1:9999",

    # 当servermode为single的时候，需要设置下面的host/port
    # remove的时候也需要设置下面的host/port
    "host": "127.0.0.1",
    "port": 8888,

    "post": {
      "handshake": "/storagenode/handshake",
      "register": "/storagenode/register",
      "unregister": "/storagenode/unRegister",
      "remove": "/storagenode/remove"
    },
    # 逗号分隔的环境变量名列表，register时会把这些环境变量的值发给master。
    # 发给master的key格式为:ENV_<env_name>。
    "register_env_vars" : "NODE_AFFINITY,PALLAS_STORAGE,POD_NAME"
  },

  "host": "0.0.0.0",
  "port": 9999,
  "pidfile": "storage.9999.pid",
  "db_dir": "db",
  # 多个临时目录用|分隔
  "tmp_dirs": "db/tmp",
  "clean_threshold_modcnt": 1000,
  # tmp_dirs缺省位于db目录下，如果把它改成其他目录，并且和db目录不在同一个文件系统里，
  # 那么必须把ingest_use_move改为false。
  "ingest_use_move": true,
  # 限制允许并发执行的ingest数(不是接收到的并发ingest数，目前grpc无法限制这个)。
  # 假如同时接收到10个ingest请求，每个ingest的数据量是100MB，那么就只允许执行其中5个，另外5个等待。
  # 可以用sdo(setdboptions)命令修改该配置项(但不会更新配置文件中的值)。
  "ingest_concurrent_recv_size_limit": "500MB",

  # log configuration
  "log_file": "pallas.storage.log",
  "log_file_maxsize": "10MB",
  "lof_file_cnt": 4,
  "log_flush_everyone": true,

  # rpc相关的配置
  "grpc_max_recv_msg_size": "500MB",
  "grpc_max_send_msg_size": "500MB",
  # 每次发送的数据量是: shardread_cnt_once条记录或者数据量达到grpc_max_send_msg_size * shardread_grpc_msg_size_limit。
  "shardread_cnt_once": 10000,
  "shardread_grpc_msg_size_limit": 0.9,

  "enable_compact_deletion" : false,
  "compact_deletion_nap_time" : "5min",
  "compact_deletion_threshold" : 100,

  # host-based access control
  # 每项的格式: "ipaddrs allow|deny"。
  # 其中ipaddrs有2种格式:
  #   1) a.b.c.d1,d2-d3,d4,d5  最后一部分是逗号分隔的列表，列表中的项可以是个数字或者数字范围。
  #   2) a.b.c.d/n  前n位匹配。
  "hba" : [
    "127.0.0.1 allow",
    "192.168.1.79/16 allow",
    "172.16.0.0/12 allow",
    "10.244.0.0/16 allow",

    # last empty array item
    ""
  ],

  # db_options和cf_options/<xxx>是数组，数组元素是串，串的格式为"name1=val1 name2=val2 ..."。
  "rocksdb": {
    "cache_size": "512MB",
    # 当memtable中没有flush的数据量达到trigger_flush_size，
    # 并且维持的时间达到了trigger_flush_time，
    # 那么会执行手动flush。
    "trigger_flush_size": "512MB",
    "trigger_flush_time": "10min",
    "db_options": [
      "max_total_wal_size=2GB",
      #"WAL_ttl_seconds=0",
      #"WAL_size_limit_MB=0",
      #"wal_recovery_mode=kPointInTimeRecovery",
      "delete_obsolete_files_period_micros=30min",
      "keep_log_file_num=4",
      "max_log_file_size=10MB",
      #"log_file_time_to_roll=0",
      #"recycle_log_file_num=0",
      #"max_manifest_file_size=100MB",
      "max_background_jobs=8",
      #"max_subcompactions=1",
      #"stats_dump_period_sec=10min",
      #"enable_pipelined_write=false",
      #"allow_concurrent_memtable_write=true",
      #"enable_write_thread_adaptive_yield=true",
      #"write_thread_max_yield_usec=100",
      #"write_thread_slow_yield_usec=3",
      #"db_write_buffer_size=0",
      #"manual_wal_flush=false",

      # last empty array item
      ""
    ],
    # cf_options/后面是column family名字，目前有3个cf：default/system/blob。
    # default cf保存用户表的数据；system cf保存系统字典；blob cf保存BLOB数据。
    "cf_options/default": [
      "write_buffer_size=256MB",
      "max_write_buffer_number=4",
      "max_write_buffer_number_to_maintain=2",
      #"min_write_buffer_number_to_merge=1",
      #"num_levels=7",
      "compression=kLZ4HCCompression",
      #"level0_file_num_compaction_trigger=4",
      #"level0_slowdown_writes_trigger=20",
      #"level0_stop_writes_trigger=36",
      "max_bytes_for_level_base=4GB",
      #"max_bytes_for_level_multiplier=10",
      "target_file_size_base=256MB",
      "target_file_size_multiplier=2",
      #"compaction_style=kCompactionStyleLevel",
      #"compaction_pri=kByCompensatedSize",

      # last empty array item
      ""
    ],
    "cf_options/system": [
      "write_buffer_size=32MB",
      "max_write_buffer_number=2",
      "max_write_buffer_number_to_maintain=2",
      #"min_write_buffer_number_to_merge=1",
      #"num_levels=7",
      "compression=kLZ4HCCompression",
      #"level0_file_num_compaction_trigger=4",
      #"level0_slowdown_writes_trigger=20",
      #"level0_stop_writes_trigger=36",
      "max_bytes_for_level_base=512MB",
      #"max_bytes_for_level_multiplier=10",
      "target_file_size_base=32MB",
      "target_file_size_multiplier=2",
      #"compaction_style=kCompactionStyleLevel",
      #"compaction_pri=kByCompensatedSize",

      # last empty array item
      ""
    ],
    "cf_options/blob": [
      "write_buffer_size=256MB",
      "max_write_buffer_number=4",
      "max_write_buffer_number_to_maintain=1",
      #"min_write_buffer_number_to_merge=1",
      #"num_levels=7",
      "compression=kNoCompression",
      #"level0_file_num_compaction_trigger=4",
      #"level0_slowdown_writes_trigger=20",
      #"level0_stop_writes_trigger=36",
      "max_bytes_for_level_base=10GB",
      #"max_bytes_for_level_multiplier=10",
      "target_file_size_base=256MB",
      "target_file_size_multiplier=2",
      #"compaction_style=kCompactionStyleLevel",
      #"compaction_pri=kByCompensatedSize",

      # last empty array item
      ""
    ],
    # 指定cf使用那些目录，rocksdb会把最新的数据优先放在前面的目录，老数据放在后面的目录。
    # 每项的格式为：path:size。size表示在path目录下最多使用多少空间。
    # 特殊path值<cfname>表示在db目录下和cf同名的目录，如果没有指定<cfname>项则会自动在开头添加它。
    "cf_paths/default": [
      #"<cfname>:0",
      #"/path/to/xxx:10GB",

      # last empty array item
      ""
    ],
    "cf_paths/blob": [
      #"<cfname>:0",
      #"/path/to/xxx:10GB",

      # last empty array item
      ""
    ]
  }
}