
env JAVA_HOME;
env YARN_CONF_DIR;
env BATCH_WORKER_HOME;
env CARPO_HOME;
env ZK_LIST;
env CARPO_ZK_LIST;
env KAFKA_ZK_LIST;
env KAFKA_BROKER_LIST;
env GRASSLAND_SERVER_LIST;
env CARPO_LOGKEEPER;
env JAVA_CMD;

env GRASSLAND_APP_TITLE_PREFIX;

#daemon  off;

#master_process  off;

#user  nobody;
worker_processes  1;

error_log  logs/error.log;

#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid    grassland-server.pid;


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

    jvm_options "-Dsun.java.command=grassland-server[worker#{pno}]";

    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }

    gzip on;
    #gzip_http_version 1.0;
    gzip_disable "MSIE [1-6].";
    gzip_types application/javascript text/plain  application/x-javascript text/css text/javascript  application/json  "application/json; charset=UTF-8";

    server {
       listen       ${GRASSLAND_SERVER_LIST};
       server_name  localhost;

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

       root ${GRASSLAND_WEBAPP_PARENT}/webapp/;

       location / {
          try_files $uri $uri/index.html;
       }

       set $rootConfig "";

       location /api {
          content_handler_type java;
          content_handler_name com.datapps.grassland.rest.security.NginxSpringJerseyHandler;
          content_handler_property server com.datapps.linkoopdb.server.Server;
          content_handler_property jersey-resource-config jerseyResourceConfig;
          content_handler_property jersey-context-path /api;
          ${GRASSLAND_ROOT_CONFIG};
          client_max_body_size 10m;
       }




    }

}