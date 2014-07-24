# Build: docker build -t environment .
# Run: docker run --name <environment> environment

FROM localhost:5000/ubuntu
MAINTAINER = Ruedi Steinmann <ruediste@gmail.com>

# Install Packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y git

# Add run script
ADD run.sh /run.sh
RUN chmod +x /run.sh

VOLUME /env
