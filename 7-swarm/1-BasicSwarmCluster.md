### Docker Swarm

![Swarm Architecture](https://res.cloudinary.com/deey9oou3/image/upload/v1547419575/swarm-diagram.png)

##### - To basically set up a swarm claster with 1 manager and 2 workers

On vagrant-manager: 
```
docker swarm init --advertise-addr 192.168.205.10
```
1: After run command above, the information below will show up
```
docker swarm join --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx 172.17.0.2:2377
```
2: Copy this command and run in two vagrant-workers
3: To check the status of swarm node
```
$ docker node ls
ID                           HOSTNAME        STATUS  AVAILABILITY  MANAGER STATUS
1bcef6utixb0l0ca7gxuivsj0    swarm-worker2   Ready   Active
38ciaotwjuritcdtn9npbnkuz    swarm-worker1   Ready   Active
e216jshn25ckzbvmwlnh5jr3g *  swarm-manager   Ready   Active        Leader
```
- findings: I read the article about [Raft Algorithm](https://medium.freecodecamp.org/in-search-of-an-understandable-consensus-algorithm-a-summary-4bc294c97e0d) which gives me a better understanding of manager status.
![rules in raft algorithm](https://res.cloudinary.com/deey9oou3/image/upload/v1547548859/1__B3mkKkJiCXJDQJNdd17KA.png)

##### - Create Service in swarm cluster
My own understanding in Service of docker swarm is that service here is actually a container. Unlike the service in docker-compose file, the service will not be created on localhost, it will be randomly allocated to the node or nodes in swarm cluster.  

1: Create docker service in swarm cluster is similar to `docker run` on localhost
```
docker service create --name demo busybox sh -c "while true;do sleep 3600;done"
```
2: To check services information
```
docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
my3zlqi1yf0a        demo                replicated          1/1                 busybox:latest
```
3: To know which node the service is allocated to
```
docker service ps <NAME>
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
3ipon0k0c9nd        demo.1              busybox:latest      swarm-manager       Running             Running 8 minutes ago
```

##### - Scaling services
1: To scale service, we can run command below, then services will be allocated to different nodes of cluster.
```
docker service scale SERVICE=REPLICAS [SERVICE=REPLICAS...]
```
Now we can see the result **REPLICAS 5/5** after we run `docker service ls`. The first 5 means 5 services are ready, second one means the number of replicas is 5.
```
[vagrant@swarm-manager ~]$ docker service ps demo
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
3ipon0k0c9nd        demo.1              busybox:latest      swarm-manager       Running             Running 20 minutes ago
5kq4w99o5u9o        demo.2              busybox:latest      swarm-worker2       Running             Running 3 minutes ago
nx1zfqojuz4g        demo.3              busybox:latest      swarm-worker2       Running             Running 3 minutes ago
rx9s32r45u1z        demo.4              busybox:latest      swarm-manager       Running             Running 3 minutes ago
zmmszomi3hgz        demo.5              busybox:latest      swarm-worker1       Running             Running 3 minutes ago
```

2: Another feature of scaling is that docker swarm will maintain the number of ready services. This is another feature of scaling. if we force to remove a service on worker, another service will be created on other workers, swarm will make sure the number of running service equal to the number of replicas.
```
[vagrant@swarm-worker1 ~]$ docker rm -f 8153da8fe76a
```
```
[vagrant@swarm-manager ~]$ docker service ps demo
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR       PORTS
3ipon0k0c9nd        demo.1              busybox:latest      swarm-manager       Running             Running 30 minutes ago
5kq4w99o5u9o        demo.2              busybox:latest      swarm-worker2       Running             Running 13 minutes ago
nx1zfqojuz4g        demo.3              busybox:latest      swarm-worker2       Running             Running 13 minutes ago
rx9s32r45u1z        demo.4              busybox:latest      swarm-manager       Running             Running 13 minutes ago
hfuobhqmj3j4        demo.5              busybox:latest      swarm-worker1       Running             Running 14 seconds ago
zmmszomi3hgz         \_ demo.5          busybox:latest      swarm-worker1       Shutdown            Failed 20 seconds ago    "task: non-zero exit (137)"
```
To remove the service we can simply run: `docker service rm <NAME>`