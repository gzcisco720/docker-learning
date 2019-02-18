### Tools
To copy local files into VMs, using vagrant-scp plugin will be a good idea.

- `vagrant plugin install vagrant-scp`  instal  vagrant scp on your local
- Getting into third section and run `vagrant up`
-  `vagrant scp ../5-volume/labs host:/home/vagrant/5-labs` copy labs o local machine into VM 5-labs directory

### Volume
Normally use Volume to store the data of mysql
```
1: docker pull mysql
2: docker run --name mysql -d -v mysql:/var/lib/mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql
3: docker volume ls # To check new Volume
4: # get into container and create a database 
5: # delete mysql contianer and create a new mysql container with -v mysql:/var/lib/mysql to reuse the volume
```
2: Bind Mount
The purpose of this experiment is to sync files between my Macos, vagrant VM and flask container, so that I can do programming based on VM docker environment.
- In Vagrantfile, I added two lines below
```
1: config.vm.network "forwarded_port", guest: 80, host: 8988 # To forward VM port 80 to Macos port 8988
2: config.vm.synced_folder "./", "/home/vagrant/labs" # To sync files on mac with VM
```
- Run Container with  Bind Mount
```
1: docker build -t skeleton . # Run this command under flask-skeleton folder to buid flask-skeleton image
2: docker run -d -p 80:5000 -v $(pwd):/skeleton --name flask-skeleton skeleton # Run container with Bind Mount
```
**Now You can check the result on your laptop's browser with localhost:8988 and change the source code on your laptop, then magic will happen.**

To auto refresh the browser, I recommand Chrome Extension [Super Simple Auto Refresh.](https://chrome.google.com/webstore/detail/super-simple-auto-refresh/gljclgacfalmnebgmhknodlplmngmfpi?hl=en)