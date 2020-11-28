FROM nginx:latest

MAINTAINER Simone Riggi "simone.riggi@gmail.com"

######################################
##   DEFINE CUSTOMIZABLE ARGS/ENVS
######################################
ARG PORT_ARG=5000
ENV PORT $PORT_ARG

ARG SERVERS_ARG="127.0.0.1:3031"
ENV SERVERS $SERVERS_ARG

######################################
##     INSTALL SYS LIBS
######################################
# - Install packages
RUN apt-get update && apt-get --no-install-recommends install -y nano


######################################
##     SET RUN OPTIONS
######################################
# - Make run dir
RUN mkdir -p /opt/nginx

# - Copy run script
COPY run_nginx.sh /opt/nginx/run_nginx.sh
RUN chmod +x /opt/nginx/run_nginx.sh

# - Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# - Expose container port
EXPOSE $PORT

# - Run nginx using a script
CMD ["bash", "-c", "/opt/nginx/run_nginx.sh --port=$PORT --servers=$SERVERS"]

