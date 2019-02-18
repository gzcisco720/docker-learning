# Setup K8s Cluster with Kubeadm and Flannel network for Centos
1: Install Docker, rpm package download link.
https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
Right now, k8s suggests user to use docker 18.06
```
sudo yum update
sudo yum install labs/TwoNodeCluster/docker-ce-18.06.0.ce-3.el7.x86_64.rpm
sudo systemctl enable docker.service && sudo systemctl start docker
```
2: Switch off Swap and SELinux
```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```
3: Install kubelet kubeadm kubectl
```
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF'
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
```
4: Add Iptable config (Centos Only)
```
sudo bash -c 'cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sudo sysctl --system
```
5: Init Cluster Master (Master Only)
```
sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address 192.168.205.10

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
6: Init Flannel Network (Master Only)
```
// This is for our case
// The reason why we use this file is that Vagrant will tend to use the first Iface (eth0) as the host, but we need to set --iface to eth1.
// So I added a new arg under kube-flannel section of kube-flannel.yml

kubectl apply -f labs/TwoNodeCluster/kube-flannel.yml

// This is for normal Use such as production enviroment and cloud platform
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
7: Join cluster (Worker Only)
```
kubeadm join 192.168.205.10:6443 --token uwlb7d.ybtb21z20bd3et1m --discovery-token-ca-cert-hash sha256:d3a055126f4d733f7de4e059f350fa4074e52845854dd07f50b657c08eab1eb5
```
8: create deployment and service
```
kubectl create -f labs/TwoNodeCluster/nginx-deployment.yml
kubectl expose deployment nginx-deployment --type=NodePort
```