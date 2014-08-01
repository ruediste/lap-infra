FROM localhost:5000/infra_ubuntu

RUN apt-get install -y python-software-properties software-properties-common \
	supervisor logrotate mysql-client\
	&& apt-get clean

RUN add-apt-repository -y ppa:brightbox/ruby-ng && apt-get update
RUN	apt-get install -y make imagemagick nginx \
      memcached subversion git ruby2.1 \
      ruby2.1-dev libcurl4-openssl-dev libssl-dev \
      libmagickcore-dev libmagickwand-dev libmysqlclient-dev libpq-dev \
      libxslt1-dev libffi-dev libyaml-dev zlib1g-dev \
      && apt-get clean
      
RUN gem install --no-ri --no-rdoc bundler && \
    apt-get clean # 20140519

ADD assets/setup/ /redmine/setup/
RUN chmod 755 /redmine/setup/install
RUN /redmine/setup/install


ADD assets/config/ /redmine/setup/config/
ADD assets/init /redmine/init
RUN chmod 755 /redmine/init 

# fix for strange permission problem
RUN mv /redmine/setup /redmine/setup1 && cp -r /redmine/setup1 /redmine/setup && chown -R www-data: /redmine/setup 

EXPOSE 80
VOLUME ["/redmine/files"]

#ENTRYPOINT ["/redmine/init"]
#CMD ["app:start"]
