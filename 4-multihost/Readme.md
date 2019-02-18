## Overlay Network

### A simple example of multi host overlay network
![overlay network sample](https://res.cloudinary.com/deey9oou3/image/upload/v1546813728/Screen_Shot_2019-01-07_at_9.20.23_am.png)
##### Docker implement overlay network based on [VXLAN](https://www.cisco.com/c/en/us/products/collateral/switches/nexus-9000-series-switches/white-paper-c11-729383.html)
![VXLAN](https://res.cloudinary.com/deey9oou3/image/upload/v1546814156/Screen_Shot_2019-01-07_at_9.35.34_am.png)
In short, VXLAN is a technology that wraps a data package twice with different networking information, and then unwrapping it from another side.
**For example**, according to first screenshot, data is wrapped with ip info (src 172.17.0.2 dest 172.17.0.3), then host1 will wrap the entire package with ip info (src 192.168.205.10 dest 192.168.205.11). When host2 receive the package, it will unwrap the package and send to docker0, then send to flask-redis. vice versa.
#### How to create a overlay network manually ?
Ectd is required, etcd is "A distributed, reliable key-value store for the most critical data of a distributed system." The reason why etcd is needed is to make each docker host share their docker status.

**On node one**

```
ubuntu@docker-node1:~$ wget https://github.com/coreos/etcd/releases/download/v3.0.12/etcd-v3.0.12-linux-amd64.tar.gz
ubuntu@docker-node1:~$ tar zxvf etcd-v3.0.12-linux-amd64.tar.gz
ubuntu@docker-node1:~$ cd etcd-v3.0.12-linux-amd64
ubuntu@docker-node1:~$ nohup ./etcd --name docker-node1 --initial-advertise-peer-urls http://192.168.205.10:2380 \
--listen-peer-urls http://192.168.205.10:2380 \
--listen-client-urls http://192.168.205.10:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.205.10:2379 \
--initial-cluster-token etcd-cluster \
--initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
--initial-cluster-state new&
```
**On node two**

```
ubuntu@docker-node2:~$ wget https://github.com/coreos/etcd/releases/download/v3.0.12/etcd-v3.0.12-linux-amd64.tar.gz
ubuntu@docker-node2:~$ tar zxvf etcd-v3.0.12-linux-amd64.tar.gz
ubuntu@docker-node2:~$ cd etcd-v3.0.12-linux-amd64/
ubuntu@docker-node2:~$ nohup ./etcd --name docker-node2 --initial-advertise-peer-urls http://192.168.205.11:2380 \
--listen-peer-urls http://192.168.205.11:2380 \
--listen-client-urls http://192.168.205.11:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.205.11:2379 \
--initial-cluster-token etcd-cluster \
--initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
--initial-cluster-state new&
```

**To check claster status**

```
ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl cluster-health
member 21eca106efe4caee is healthy: got healthy result from http://192.168.205.10:2379
member 8614974c83d1cc6d is healthy: got healthy result from http://192.168.205.11:2379
cluster is healthy
```
**Restart docker services**

**On node one**

```
$ sudo service docker stop
$ sudo /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.10:2379 --cluster-advertise=192.168.205.10:2375&
```

**On node two**

```
$ sudo service docker stop
$ sudo /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.11:2379 --cluster-advertise=192.168.205.11:2375&
```
**Now Magic will happen,** create a overlay network on node one `sudo docker network create -d overlay demo`, then check node2's network. The new overlay network can also be seen on node2.

```
ubuntu@docker-node1:~$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
0e7bef3f143a        bridge              bridge              local
3d430f3338a2        demo                overlay             global
a5c7daf62325        host                host                local
3198cae88ab4        none                null                local
```
```
ubuntu@docker-node2:~$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
c9947d4c3669        bridge              bridge              local
3d430f3338a2        demo                overlay             global
fa5168034de1        host                host                local
c2ca34abec2a        none                null                local
```

