log4j.rootCategory={{ .Values.database.config.logLevel | default "WARN" }}, CONSOLE, FILE
log4j.logger.AUDIT=INFO, AUDIT_FILE
log4j.additivity.AUDIT=false
LOG_PATH=${linkoopdb.logs.dir}/${linkoopdb.com.name}
LOG_FILE=${LOG_PATH}/${linkoopdb.com.name}.log
AUDIT_LOG_FILE=${LOG_PATH}/${linkoopdb.com.name}-HA.log
LOG_LEVEL_PATTERN=%5p
LOG_PATTERN=[%d{yyyy-MM-dd HH:mm:ss.SSS}] %X{pid} ${LOG_LEVEL_PATTERN} [%t] --- %c{1}: %m%n %throwable{1000}
# CONSOLE is set to be a ConsoleAppender using a PatternLayout.
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.Encoding=UTF-8
log4j.appender.CONSOLE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=${LOG_PATTERN}
log4j.appender.FILE=org.apache.log4j.DailyRollingFileAppender
log4j.appender.FILE.File=${LOG_FILE}
log4j.appender.FILE.Encoding=UTF-8
log4j.appender.FILE.DatePattern=.yyyy-MM-dd
#log4j.appender.FILE.MaxFileSize=10MB
log4j.appender.FILE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.FILE.layout.ConversionPattern=${LOG_PATTERN}
log4j.appender.AUDIT_FILE=org.apache.log4j.DailyRollingFileAppender
log4j.appender.AUDIT_FILE.File=${AUDIT_LOG_FILE}
log4j.appender.AUDIT_FILE.Encoding=UTF-8
log4j.appender.AUDIT_FILE.DatePattern=.yyyy-MM-dd
#log4j.appender.FILE.MaxFileSize=10MB
log4j.appender.AUDIT_FILE.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.AUDIT_FILE.layout.ConversionPattern=[%d{yyyy-MM-dd HH:mm:ss.SSS}] %m%n %throwable{1000}
log4j.category.org.apache.catalina.startup.DigesterFactory=ERROR
log4j.category.org.apache.catalina.util.LifecycleBase=ERROR
log4j.category.org.apache.coyote.http11.Http11NioProtocol=WARN
log4j.category.org.apache.sshd.common.util.SecurityUtils=WARN
log4j.category.org.apache.tomcat.util.net.NioSelectorPool=WARN
log4j.category.org.crsh.plugin=WARN
log4j.category.org.crsh.ssh=WARN
log4j.category.org.eclipse.jetty.util.component.AbstractLifeCycle=ERROR
log4j.category.org.glassfish.jersey.servlet=ERROR
log4j.category.org.hibernate.validator.internal.util.Version=WARN
log4j.category.org.springframework.boot.actuate.autoconfigure.CrshAutoConfiguration=WARN
log4j.category.org.springframework.boot.actuate.endpoint.jmx=WARN
log4j.category.org.thymeleaf=WARN
log4j.category.org.quartz=INFO
log4j.category.com.atomikos=WARN
log4j.category.org.springframework=WARN
log4j.category.org.apache.solr=WARN
log4j.category.org.apache.zookeeper=WARN
log4j.category.com.datapps=INFO
#log4j.category.com.datapps.carpo.executor.service.ExecutorService=WARN
log4j.category.nokafka=INFO,CONSOLE, FILE
log4j.additivity.nokakfa=false

