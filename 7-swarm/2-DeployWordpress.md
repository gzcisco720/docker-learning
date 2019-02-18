### Deploy a wordpress in Swarm

1: Considering that wordpress service and mysql service need to communicate with each other, a network need to be created. Overlay network need to be choosen becuase services will be allocated to different node.
```
[vagrant@swarm-manager ~]$ docker network create -d overlay <NAME>          
```
After runing the command above, we would expact that demo network can be seen in the network list, but there is no new network can be seen. The reason why this happens is that there is no service connecting to this network. So next we will create a service.

2 Create services
```
docker service create --name mysql --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=wordpress --network demo --mount type=volume,source=mysql-data,destination=/var/lib/mysql mysql:5.7

docker service create --name wordpress -p 80:80 --env WORDPRESS_DB_PASSWORD=root --env WORDPRESS_DB_HOST=mysql:3306 --network demo wordpress
```
3: Now, we can use commands to scale wordpress service in Swarm. run `docker service scale wordpress=2`
```
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR                         PORTS
ct1v683nstuu        wordpress.2         wordpress:latest    swarm-worker1       Running             Running 55 seconds ago
xi5vgh659uqs        wordpress.3         wordpress:latest    swarm-worker2       Running             Running 55 seconds ago
```
Then it can be found that wordpress is running on swarm-worker1 and swarm-worker2, so that we can enter the ip addresses of worker 1 and worker 2 in our browser. Boo! wordpress page shows up. Interestingly, although there is no wordpress service running on swarm-manager, we can visit the page by entering swarm-manager's ip address. The reason for this is "Routing Mesh" and next note will explain it in detail.