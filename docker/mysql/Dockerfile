FROM localhost:5000/infra_ubuntu

RUN	apt-get install -y mysql-server && \
		rm -rf /var/lib/mysql/mysql && \
		apt-get clean 

ADD start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 3306
VOLUME ["/var/lib/mysql"]
CMD ["/start.sh"]
