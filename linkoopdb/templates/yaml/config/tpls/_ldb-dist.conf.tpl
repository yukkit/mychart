env JAVA_HOME;
env JAVA_CMD;
env GRASSLAND_APP_TITLE_PREFIX;

worker_processes  1;

error_log  logs/error.log;

pid    ldb-dist.pid;

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

    root ${LDBDIST_ROOT_DIR};

    keepalive_timeout  65;

    # java configuration
    jvm_path auto;
    jvm_classpath "${JVM_CLASSPATH}";
    jvm_classpath_check off;
    jvm_options '-Dfile.encoding=utf8';
    ${JVM_OPTS}
    #for enable java remote debug uncomment next two lines
    #jvm_options "-Xdebug";
    #jvm_options "-Xrunjdwp:server=y,transport=dt_socket,address=9527,suspend=n";

    jvm_options "-Dsun.java.command=ldb-dist-[worker#{pno}]";

    ###threads number for request handler thread pool on jvm, default is 0.
    jvm_workers 0;

    gzip on;
    #gzip_http_version 1.0;
    gzip_disable "MSIE [1-6].";
    gzip_types application/javascript text/plain  application/x-javascript text/css text/javascript  application/json  "application/json; charset=UTF-8";

    server {
           listen       ${LDBDIST_SERVER_PORT};

           #charset utf-8;

           access_log  logs/access_$year-$month-$day.log main;

           client_max_body_size 100m;

           error_page  404              /404.html;
           error_page  500              /500.html;
           error_page  502              /502.html;
           error_page  503 504          /50x.html;

           if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
              set $year $1;
              set $month $2;
              set $day $3;
           }

           location / {
              content_handler_type java;
              content_handler_name com.datapps.linkoopdb.ldbdist.server.LDBDistNginxHandler;
              content_handler_property root-directory ${LDBDIST_SERVER_FILE_DIR};
           }

     }

}