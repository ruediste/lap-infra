FROM localhost:5000/ubuntu
MAINTAINER = Ruedi Steinmann <ruediste@gmail.com>

# download first, the more volatile aspects come later
RUN apt-get install -y gitolite

ADD debconf_selections /debconf_selections
ADD admin_rsa.pub /admin_rsa.pub

RUN debconf-set-selections /debconf_selections
RUN dpkg-reconfigure -fnoninteractive gitolite

RUN mkdir /var/run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
