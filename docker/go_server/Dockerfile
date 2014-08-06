FROM localhost:5000/infra_java
MAINTAINER = Ruedi Steinmann <ruediste@gmail.com>

RUN wget http://download.go.cd/gocd-deb/go-server-14.2.0-377.deb

RUN dpkg -i go-server-14.2.0-377.deb

RUN mv /etc/go/ /etc/go-template/
ADD start.sh /start.sh
RUN chmod 755 /start.sh 