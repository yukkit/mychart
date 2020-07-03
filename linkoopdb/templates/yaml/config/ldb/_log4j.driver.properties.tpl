# Set everything to be logged to the console
log4j.rootCategory=INFO, CONSOLE, FILE, LOCAL_FILE
LOG_PATH=${linkoopdb.logs.dir}
LOG_FILE=${LOG_PATH}/${linkoopdb.com.name}.log
LOG_PATTERN=[%d{yyyy-MM-dd HH:mm:ss.SSS}] %X{pid} ${LOG_LEVEL_PATTERN} [%t] --- %c{1}: %m%n %throwable{1000}
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=${LOG_PATTERN}
log4j.appender.FILE=com.datapps.linkoopdb.worker.spark.TaskGroupPallasClobAppender
log4j.appender.FILE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.FILE.layout.ConversionPattern=${LOG_PATTERN}
log4j.appender.LOCAL_FILE=org.apache.log4j.DailyRollingFileAppender
log4j.appender.LOCAL_FILE.File=${LOG_FILE}
log4j.appender.LOCAL_FILE.Encoding=UTF-8
log4j.appender.LOCAL_FILE.DatePattern=.yyyy-MM-dd
#log4j.appender.LOCAL_FILE.MaxFileSize=10MB
log4j.appender.LOCAL_FILE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.LOCAL_FILE.layout.ConversionPattern=${LOG_PATTERN}
# Set the default spark-shell log level to WARN. When running the spark-shell, the
# log level for this class is used to overwrite the root logger's log level, so that
# the user can have different defaults for the shell and regular Spark apps.
log4j.logger.org.apache.spark.repl.Main=WARN
# Settings to quiet third party logs that are too verbose
log4j.logger.org.spark_project.jetty=WARN
log4j.logger.org.spark_project.jetty.util.component.AbstractLifeCycle=ERROR
log4j.logger.org.apache.spark.repl.SparkIMain$exprTyper=INFO
log4j.logger.org.apache.spark.repl.SparkILoop$SparkILoopInterpreter=INFO
log4j.logger.org.apache.parquet=ERROR
log4j.logger.parquet=ERROR
# SPARK-9183: Settings to avoid annoying messages when looking up nonexistent UDFs in SparkSQL with Hive support
log4j.logger.org.apache.hadoop.hive.metastore.RetryingHMSHandler=FATAL
log4j.logger.org.apache.hadoop.hive.ql.exec.FunctionRegistry=ERROR
