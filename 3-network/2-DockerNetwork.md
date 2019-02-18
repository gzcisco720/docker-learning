## Docker Network

**Five network drivers**: `bridge`, `overly`, `host`,`macvlan`,`none`. 
[To see detail here.](https://docs.docker.com/network/)

## Note and Findings

- **bridge (the most commonly used network):** 
![docker network](http://blog.daocloud.io/wp-content/uploads/2015/01/Docker_Topology.jpg)
![experiment screenshot](https://res.cloudinary.com/deey9oou3/image/upload/v1546737689/Screen_Shot_2019-01-06_at_12.06.06_pm.jpg)
**From the screenshot above, we can see how containers are connected via bridge network with veth pairs.**

- **About `Link`:** 
`link` is usually used to link two containers, so that the linked container can be reached by using its name. For example: After linking wordpress and mysql, mysql can be reached in wordpress container by `ping mysql:3306`. 
The reason how it works is that [an embeded DNS Server](https://docs.docker.com/v17.09/engine/userguide/networking/configure-dns/) is running in docker engine. If contianers are linked with each other via default bridage (docker0), they should be linked manually by using `--link`. 
User-defined networks are recommended by official because of "User-defined bridges provide automatic DNS resolution between containers." and [other advantages.](https://docs.docker.com/network/bridge/#differences-between-user-defined-bridges-and-the-default-bridge) 

- **Findings about docker on Mac and Windows:** 
**Question on stackoverflow:** Why I cannot ping my running container via its ip on my Mac ?
**[Findings]:** Docker for mac and windows are actually running in a virtual machine. So there is no docker network which can be found in Macos or windows.
![experiment screenshot](https://res.cloudinary.com/deey9oou3/image/upload/v1546739240/Screen_Shot_2019-01-06_at_12.46.54_pm.png)
It's like using docker machine to operate the remote docker server.
- **An interesting experiment about docker-machine from myself:**
1: Stopping docker server on my Macos, as we can see there is no docker server being running on my local.
![experiment screenshot 1](https://res.cloudinary.com/deey9oou3/image/upload/v1546739912/Screen_Shot_2019-01-06_at_12.58.02_pm.png)
2: Creating a docker machine on my Mac and running `docker-machine ssh <Name>` and `docker version` to check the status of docker machine.
![experiment screenshot 2](https://res.cloudinary.com/deey9oou3/image/upload/v1546740143/Screen_Shot_2019-01-06_at_1.01.46_pm.png)
3: On your Mac terminal, run `docker-machine env <Name>` to export docker machine's env variables, and then run`eval $(docker-machine env demo)` to connect docker server in docker machine.
![experiment screenshot 3](https://res.cloudinary.com/deey9oou3/image/upload/v1546740345/Screen_Shot_2019-01-06_at_1.05.16_pm.png)
4: Now running `docker version` on your Mac, you can see docker server is back(the server in docker machine).
![experiment screenshot 4](https://res.cloudinary.com/deey9oou3/image/upload/v1546740542/Screen_Shot_2019-01-06_at_1.08.45_pm.png)

- **Q&A from myself:**
**Q:** Given docker for mac is running in a VM, why I can still check the service (such as Nignx which is running in container) on my localhost:80 when I use `-p 80:80` rather than accessing it via VM's IP with port 80?
**A:** Port_forwarding, to replicate how docker for mac working, I created a VM by using vagrant with extra config below
`config.vm.network "forwarded_port", guest: 80, host: 8080`
Now we can access to the service in VM via localhost. But the way docker implements this are more dynamically. 

- **About Host and None Network:**
-- If a contianer is running in host network, it means that this container is sharing a same network namespace with docker host machine. The issue I found is that there will be conflicts on ports between host and containers.
-- Still hav no I idea when to use none network