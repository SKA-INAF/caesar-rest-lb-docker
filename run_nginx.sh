#!/bin/bash

##########################
##    PARSE ARGS
##########################
PORT=5000
SERVERS="127.0.0.1:3031"

for item in "$@"
do
	case $item in 
		
		--port=*)
    	PORT=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--servers=*)
    	SERVERS=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;

	*)
    # Unknown option
    echo "ERROR: Unknown option ($item)...exit!"
    exit 1
    ;;
	esac
done

echo "PORT: $PORT"
SERVER_LIST=($(echo $SERVERS | tr "," "\n"))
for server in "${SERVER_LIST[@]}"
do
	echo "SERVER: $server"
done


#################################
##    GENERATE NGINX CONFIG
#################################
echo "INFO: Generating nginx config file ..."
( 
  echo "upstream backend {"
  echo "  least_conn;  # load balancing strategy"
  for server in "${SERVER_LIST[@]}"
  do
	  echo "  server $server;"
  done
  echo "  keepalive 64;"
  echo "}"

	echo ""

	echo "server {"
  echo "  listen $PORT;"
	#echo "  server_name 127.0.0.1;"	
  echo "  client_max_body_size 1000M;"
	echo "  large_client_header_buffers 4 32k;"
  echo "  sendfile on;"
	echo "  keepalive_timeout 0;"
	echo "  location / {"
	#echo '    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;'
	#echo '    proxy_set_header Host $http_host;'
  #echo "    proxy_redirect off;"
  #echo '    proxy_set_header Host $host;'
	echo "    include uwsgi_params;"
  echo "    uwsgi_pass backend;"
	#echo '    proxy_set_header Host $http_host;'
	#echo '    proxy_set_header X-Forwarded-For $remote_addr;'
	echo "  }"
  echo "}" 
) > /etc/nginx/conf.d/load_balancer.conf



###############################
##    RUN NGINX
###############################
echo "INFO: Running NGINX ..."
nginx -g "daemon off;"




