### Tools

Most of experiments will be running in centos/7 VM. For quickly create VM, Vagrant is recommended.
https://www.vagrantup.com/docs/

Alternatively, Docker-machine can also be chosen.
https://docs.docker.com/machine/

Before installing the two tools above, Virtualbox need to be installed first.
https://www.virtualbox.org/wiki/Downloads

### Create VM

Vagrant go into directory which have Vagrantfile and run `vagrant up` to create VM
You can also run `vagrant init` to initialise your own VagrantFile which is written by Ruby
Run `vagrant ssh <VMName>` to login to your VM or simply run `vagrant ssh` to login to the first VM
To list VMs, run `vagrant global-status`

Docker-machine has the similar command as vagrant, but docker machine not only can provision host on
local, but also in the cloud. Details can be found https://docs.docker.com/machine/overview/

Optional: An Interesting experiment can be done by using docker-machine, Pleas try to stop the docker server on
local and use the docker server in docker-machine VM.

