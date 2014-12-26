# docker Drupal
#
# VERSION       1
# DOCKER-VERSION        1
#FROM ubuntu:14.04
FROM debian:wheezy
MAINTAINER Dmitry Zhukov <dmitry.zhukov@gmail.com>

# Install btsync
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y curl procps net-tools
RUN curl -o /usr/bin/btsync.tar.gz http://download-lb.utorrent.com/endpoint/btsync/os/linux-x64/track/stable
RUN cd /usr/bin && tar -xzvf btsync.tar.gz && rm btsync.tar.gz
RUN mkdir -p /btsync/.sync
RUN mkdir -p /var/run/btsync
RUN mkdir -p /data
RUN chown -R www-data:www-data /btsync/
RUN chown -R www-data:www-data /var/run/btsync/
#EXPOSE 55555
ADD start-btsync /usr/bin/start-btsync
RUN chmod +x /usr/bin/start-btsync
VOLUME ["/data"]

#!!#CMD ["start-btsync"]



# Install Percona XtraDB Cluster 5.6
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
RUN echo "deb http://repo.percona.com/apt wheezy main" >> /etc/apt/sources.list
RUN echo "deb-src http://repo.percona.com/apt wheezy main" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install percona-xtradb-cluster-full-56
#!!#CMD ["mysqld", "--datadir=/var/lib/mysql", "--user=mysql"]
#!!#CMD ["service", "mysql", "start"]



RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl  

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql php-apc php5-gd php5-curl php5-memcache memcached drush mc
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean

# Make mysql listen on the outside
ADD ./my.cnf /etc/my.cnf
ADD ./sed_mysql.sh /tmp/sed_mysql.sh
#!!#RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

RUN easy_install supervisor
EXPOSE 4567
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

# Retrieve drupal
RUN rm -rf /var/www/ ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
