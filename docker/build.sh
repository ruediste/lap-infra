sudo docker build -t localhost:5000/ubuntu $@ ubuntu
sudo docker build -t localhost:5000/environment $@ environment
sudo docker build -t localhost:5000/dns $@ dns

cp admin_rsa.pub gitolite/
sudo docker build -t localhost:5000/gitolite $@ gitolite