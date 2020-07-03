#!/usr/bin/env bash

# Options for license server
export LDB_LNS_HOST=${LDB_LNS_HOST:-'localhost'}
export LDB_LNS_PORT=${LDB_LNS_PORT:-'7700'}
export LDB_LNS_INTF_NAME=${LDB_LNS_INTF_NAME}
# license type. eg. 4pd/datapps
export LDB_LNS_TYPE=${LDB_LNS_TYPE:-'datapps'}

# - JAVA_HOME, JDK installation directory.
export HADOOP_USER_NAME=${HADOOP_USER_NAME:-hdfs}
export YARN_CONF_DIR=${YARN_CONF_DIR:-/etc/hadoop/conf}

# Options for linkoopdb server
export LINKOOPDB_LOGS_DIR=${LINKOOPDB_LOGS_DIR:-${LINKOOPDB_HOME}/logs}
# - LINKOOPDB_JVM_OPTS, Ldb jvm sys properties. (eg. "-Xmx4g -Xss512k -Dldb.server.sys.compact.degree=4 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=9401")
# - LINKOOPDB_META_JVM_OPTS, Ldb meta jvm sys properties. (eg. "-Xmx4g -Xss512k -Dldb.server.sys.compact.degree=4 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=9402")
# - JAVA_LIBRARY_PATH, Set hadoop native client library path. (eg. $JAVA_LIBRARY_PATH:/usr/hdp/current/hadoop-client/lib/native)
# - LD_LIBRARY_PATH, (eg. $LD_LIBRARY_PATH:/usr/hdp/current/hadoop-client/lib/native)

# Options for batch worker
export BATCH_WORKER_HOME=${BATCH_WORKER_HOME:-'/home/linkoopdb/linkoopdb/others/spark'}
# - LINKOOPDB_WORKER_JVM_OPTS, Jvm system properties. (eg. "-Xmx4g -Xss256k")
# - LINKOOPDB_META_WORKER_JVM_OPTS, Jvm system properties. (eg. "-Xmx4g -Xss256k")

# Options for stream worker
export FLINK_HOME=${FLINK_HOME:-/opt/flink}
export FLINK_CONF_DIR=${FLINK_CONF_DIR:-${FLINK_HOME}/conf}
export FLINK_LIB_DIR=${FLINK_LIB_DIR:-${FLINK_HOME}/lib}
# - STREAM_WORKER_UDF_TMP_DIR, Stream worker udf package's temporary storage directory. (Default: /tmp/linkoopdb-lstream-local-dir)
# - LINKOOPDB_STREAM_WORKER_JVM_OPTS, Ldb stream worker jvm sys properties.

# Options for ldb-dist
export LDBDIST_SERVER_FILE_DIR="/var/www/html/filesystem"
export LDBDIST_SERVER_PORT=54321
export LDBDIST_ROOT_DIR=${LDBDIST_SERVER_FILE_DIR}

# Options for ldb monitor
# - LINKOOPDB_MONITOR_SERVER_JVM_OPTS, Ldb monitor jvm sys properties.
export LINKOOPDB_MONITOR_SERVER_PORT=${LINKOOPDB_MONITOR_SERVER_PORT:-'9092'}

