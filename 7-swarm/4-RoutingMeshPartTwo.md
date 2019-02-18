### Routering Mesh in Swarm (Part Two)
**Ingress Network**
![Ingress network](https://res.cloudinary.com/deey9oou3/image/upload/v1547950049/Screen_Shot_2019-01-20_at_12.43.41_pm.png)
Even if there is no nginx web service on docker host 3, we still can visit the web service based on Ingress Network. I replicated the whole process how ingress network works.

After service "whoami" being scaled up, we can see our requests were load balanced.
```
[vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
I'm 555789d8dfe0
[vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
I'm de13ecfd1dea
[vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
I'm eca456228707
[vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
I'm 555789d8dfe0
[vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
I'm de13ecfd1dea
```
I wanted to see how our data was forwarded, I run ` sudo iptables -nL -t nat` to see the forwarding rules. Then I found all data sent to port 8000 was forwarded to 172.18.0.2:8000. What does 172.18.0.2:8000 represent? To find it out, firstly run `ip a `, it can be found that `docker_gwbridge` is under the same network. `docker_gwbridge` is more like `docker0`, it allows services to communicate with Internet.
```
5: docker_gwbridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:5b:3a:f8:e4 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.1/16 brd 172.18.255.255 scope global docker_gwbridge
       valid_lft forever preferred_lft forever
    inet6 fe80::42:5bff:fe3a:f8e4/64 scope link
```
Secondly, run `docker network inspect docker_gwbridge`. We can find that all requst to port 8000 has been forwarded to `ingress-sbox`(172.18.0.2/16)
```
"Containers": {
    ... ,
    "ingress-sbox": {
        "Name": "gateway_ingress-sbox",
        "EndpointID": "4070dd250c633b887f3152e3063741c7e4b71fc93424589edb221a1d5720a00b",
        "MacAddress": "02:42:ac:12:00:02",
        "IPv4Address": "172.18.0.2/16",
        "IPv6Address": ""
    }
},...
```
To check the interface closer, we need to get into the namespace, so wen run `sudo nsenter --net=/var/run/docker/netns/ingress_sbox` and `ip a`. we can see the namespace of hidden container `ingress_sbox`.
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
21: eth0@if22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default
    link/ether 02:42:0a:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.255.0.2/16 brd 10.255.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 10.255.0.5/32 brd 10.255.0.5 scope global eth0
       valid_lft forever preferred_lft forever
24: eth1@if25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth1
       valid_lft forever preferred_lft forever
```
In this network namespace, run `iptables -nL -t mangle` then run `ipvsadm`
```
[root@swarm-manager vagrant]# iptables -nvL -t mangle
Chain PREROUTING (policy ACCEPT 113 packets, 8666 bytes)
 pkts bytes target     prot opt in     out     source               destination
   66  4378 MARK       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8000 MARK set 0x101

Chain INPUT (policy ACCEPT 69 packets, 4816 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            10.255.0.5           MARK set 0x101

Chain FORWARD (policy ACCEPT 44 packets, 3850 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 69 packets, 4585 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 113 packets, 8435 bytes)
 pkts bytes target     prot opt in     out     source               destination
[root@swarm-manager vagrant]# ipvsadm
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
FWM  257 rr
  -> 10.255.0.6:0                 Masq    1      0          0
  -> 10.255.0.7:0                 Masq    1      0          0
  -> 10.255.0.8:0                 Masq    1      0          0
```
Now We can clearly see that data package from port 8000 has been marked as 0x101(257) `tcp dpt:8000 MARK set 0x101`. Then It would be load balanced to `10.255.0.6`,`10.255.0.7`,`10.255.0.8` which are the actual IP of `whoami` service contianers.
![Process](https://res.cloudinary.com/deey9oou3/image/upload/v1547951714/Screen_Shot_2019-01-20_at_1.34.43_pm.png)
In conclusion, we can bind all Routing Mesh knowledage together to figure out a netwroking topology of Swarm. Please check the well-drawing image below which I found from Internet.
![Architecture](https://res.cloudinary.com/deey9oou3/image/upload/v1547961272/swarm_network_view.png)
