#/bin/sh

# install some tools if you do not have vbguest plugin you can install your something here.
# https://github.com/dotless-de/vagrant-vbguest

# sudo yum install -y git vim telnet bridge-utils

# install docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

# start docker service
sudo groupadd docker
sudo usermod -aG docker vagrant
sudo systemctl start docker

rm -rf get-docker.sh
