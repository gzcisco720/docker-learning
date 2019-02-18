### Routering Mesh in Swarm (Part One)
**Internal(LVS)**
All services communicate with each other based on virtual ip rather than the real it of container. Why's that ? beacuse the real ips are always changing in cluster so they are really unstable. So virtual ip can be used to identity a service no matter how many it has been scaled up or which host they are on. But how it works ?

```
docker service create --name whoami -p 8000:8000 --network demo -d jwilder/whoami
docker service create --name demo --network demo  busybox sh -c "while true;do sleep 3600;done"
docker service scale whoami=3

ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
wl5if6ozbw3w        demo.1              busybox:latest      swarm-worker1       Running             Running 23 minutes ago

ID                  NAME                IMAGE                   NODE                DESIRED STATE       CURRENT STATE             ERROR                         PORTS
q4fx1ykw9akf        whoami.1            jwilder/whoami:latest   swarm-manager       Running             Running 12 minutes ago
apapa59uozym        whoami.2            jwilder/whoami:latest   swarm-worker2       Running             Running 2 minutes ago
wdrugo7iuwe0        whoami.3            jwilder/whoami:latest   swarm-worker1       Running             Running 2 minutes ago
```
Then `ping whoami` in busybox container on swarm-worker1. No matter how many time it has been pinged, the ip will still be 10.0.0.14 . In fact, the real ip behind this VIP was different every time, because LVS would do load balance for our services.
```
PING whoami (10.0.0.14): 56 data bytes
64 bytes from 10.0.0.14: seq=0 ttl=64 time=0.133 ms
64 bytes from 10.0.0.14: seq=1 ttl=64 time=0.084 ms
```
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
15: eth1@if16: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP
    link/ether 02:42:0a:ff:00:05 brd ff:ff:ff:ff:ff:ff
    inet 10.255.0.5/16 brd 10.255.255.255 scope global eth1
       valid_lft forever preferred_lft forever
17: eth2@if18: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:12:00:03 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.3/16 brd 172.18.255.255 scope global eth2
       valid_lft forever preferred_lft forever
19: eth0@if20: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP
    link/ether 02:42:0a:00:00:02 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 brd 10.0.0.255 scope global eth0
       valid_lft forever preferred_lft forever
```
To get closer to see how load balance and VIP working, we can use `nslookup` to check DNS table.
```
docker exec -it 5b4123f5d6e8 sh # get into busybox container
cat /etc/resolv.conf # We can get our DNS resolver's ip address
nslookup whoami 127.0.0.11 # this ip is the resolver's ip
```
Now we can find the DNS list and the VIP
```
/app # nslookup demo 127.0.0.11
Server:    127.0.0.11
Address 1: 127.0.0.11

Name:      demo
Address 1: 10.0.0.5
```
Where is the real service IP ? Run command below, All real ips will be shown in the list. LVS will pick different ip each time to achieve load balance.
```
/app # nslookup tasks.demo 127.0.0.11
Server:    127.0.0.11
Address 1: 127.0.0.11

Name:      tasks.demo
Address 1: 10.0.0.4 demo.1.w38dmrpqs2khvmjfiyw2yiyt2.demo
Address 2: 10.0.0.10 demo.3.6y2m8occrv7xj8rvbwbh5qvmn.demo
Address 3: 10.0.0.9 demo.2.vjova1kz8ics7bfv5q9l3pa99.demo
```