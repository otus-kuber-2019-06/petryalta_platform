FROM ubuntu:latest
MAINTAINER Petr Ivanov <petr.yrs@gmail.com>

ARG UNAME=nginx
ARG UID=1001
ARG GID=1001

RUN groupadd -g $GID --system $UNAME && \
    useradd -u $UID -g $GID --system  $UNAME

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:nginx/stable && \
   apt-get update && \
   apt-get install -y nginx

RUN  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
   sed -i "s/^user.*/user $UNAME $UNAME;/" /etc/nginx/nginx.conf && \
   sed -i "s/access_log.*/access_log \/dev\/stdout;/" /etc/nginx/nginx.conf && \
   sed -i "s/error_log.*/error_log \/dev\/stdout;/" /etc/nginx/nginx.conf && \
   sed -i 's/80/8000/' /etc/nginx/sites-available/default && \
   sed -i 's/root.*/root \/app;/' /etc/nginx/sites-available/default && \
   chown -R $UNAME:$UNAME /var/lib/nginx && \
   chown -R $UNAME:$UNAME /var/log/nginx

COPY ./app /app

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

WORKDIR /etc/nginx

CMD ["nginx"]

EXPOSE 8000

