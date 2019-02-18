#### Kubectl Techniques
1: Set up kubectl completion
```
kubectl completion -h   # this command will display all kinds of settings for different shell
# I am using Zsh so I get into ~/.zshrc and paste `source <(kubectl completion zsh)` at the end.
source .zshrc
```
2: Inspect merged kubeconfig settings
```
kubectl config view
========================================================
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/eric/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/eric/.minikube/client.crt
    client-key: /Users/eric/.minikube/client.key
```
The path of config file is `~/.kube/config`.

3: Easily Switch between different cluster
`kubectl config get-contexts` command will display all clusters in `~/.kube/config` file. 
```
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin
          minikube                      minikube     minikube
```
We can easily switch between them. 
*  We need to merge our `~/.kube/config` by getting into our vagrant master and running `kubectl config view --raw`
* copy the config out and merge each section with `~/.kube/config` on your local like example below
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/eric/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
- cluster:
    certificate-authority-data:...
    server: https://192.168.205.10:6443
  name: kubernetes
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/eric/.minikube/client.crt
    client-key: /Users/eric/.minikube/client.key
- name: kubernetes-admin
  user:
    client-certificate-data: ...
```
* switch between clusters by running `kubectl config set current-context <Name>`