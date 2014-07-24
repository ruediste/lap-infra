# Build: docker build -t dns .
# Run: docker run --volumes-from <environment> --name dns dns

FROM localhost:5000/ubuntu
MAINTAINER = Ruedi Steinmann <ruediste@gmail.com>

# Install Packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y bind9 bind9utils

RUN mkdir -p /var/run/named; chown bind /var/run/named

ADD etc/ /etc/bind/
RUN chown -R bind /etc/bind


EXPOSE 53

# run named under user bind and in foreground, logging to stderr
CMD ["/usr/sbin/named","-u","bind","-g", "-c","/etc/bind/named.conf"]
