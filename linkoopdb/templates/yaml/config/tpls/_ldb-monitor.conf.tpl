env JAVA_HOME;
env JAVA_CMD;
env GRASSLAND_APP_TITLE_PREFIX;

#daemon  off;
${DAEMON_SWITCH};

#master_process  off;

#user  nobody;
${USER_INFO};
worker_processes  1;

error_log  logs/error.log;

#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid  ldb-monitor.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '$request_time '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log main;

    server_tokens off;

    sendfile        on;
    #tcp_nopush     on;

    root ${LDBMONITOR_ROOT_DIR};

    #keepalive_timeout  0;
    keepalive_timeout  65;

    jvm_path auto;
    jvm_classpath "${JVM_CLASSPATH}";
    jvm_classpath_check off;
    jvm_options '-Dfile.encoding=utf8';
    ${JVM_OPTS}
    #for enable java remote debug uncomment next two lines
    #jvm_options "-Xdebug";
    #jvm_options "-Xrunjdwp:server=y,transport=dt_socket,address=840#{pno},suspend=n";

    ###threads number for request handler thread pool on jvm, default is 0.
    jvm_workers 8;

    jvm_options "-Dsun.java.command=ldb-monitor-agent[worker#{pno}]";

    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }

    gzip on;
    #gzip_http_version 1.0;
    gzip_disable "MSIE [1-6].";
    gzip_types application/javascript text/plain  application/x-javascript text/css text/javascript  application/json  "application/json; charset=UTF-8";

    server {
        listen       ${LINKOOPDB_MONITOR_SERVER_PORT};
        #server_name  localhost;

        #charset utf-8;

        access_log  logs/access_$year-$month-$day.log main;


        error_page  404              /404.html;
        error_page  500              /500.html;
        error_page  502              /502.html;
        error_page  503 504          /50x.html;

        if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
            set $year $1;
            set $month $2;
            set $day $3;
        }

        location /api {
            content_handler_type java;
            content_handler_name com.datapps.linkoopdb.monitor.agent.NginxSpringJerseyHandler;
            content_handler_property jersey-context-path /api;
            rewrite_handler_type clojure;
            always_read_body on;
            client_max_body_size 10m;
        }
    }
}