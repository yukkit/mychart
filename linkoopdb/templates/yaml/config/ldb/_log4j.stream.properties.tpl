# Set everything to be logged to the console
log4j.rootCategory=INFO, CONSOLE, file, FILE

#LOG_FILE=/fsshare/flink-worker
LOG_PATTERN=[%d{yyyy-MM-dd HH:mm:ss.SSS}] %X{pid} ${LOG_LEVEL_PATTERN} [%t] --- %c{1}: %m%n %throwable{1000}
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n

log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.file=${log.file}
log4j.appender.file.append=false
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n

log4j.logger.org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline=ERROR, file

log4j.appender.FILE=org.apache.flink.runtime.pallaslog.StreamPallasClobAppender
log4j.appender.FILE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.FILE.layout.ConversionPattern=${LOG_PATTERN}
log4j.appender.FILE.maxBufferSize=512KB
log4j.appender.FILE.interval=30000

#log4j.appender.kafka=com.datapps.message.kafka.log4jappender.KafkaLog4jAppender
#log4j.appender.kafka.topic=linkoopdb.logkeeper
## need set logkeeper use kafka broker list
#log4j.appender.kafka.brokerList=localhost:9092
#log4j.appender.kafka.compressionType=gzip
#log4j.appender.kafka.syncSend=false
#log4j.appender.kafka.layout=org.apache.log4j.EnhancedPatternLayout
#log4j.appender.kafka.layout.ConversionPattern=#%X{tag}# [%d] %p %m%n %throwable{1000}