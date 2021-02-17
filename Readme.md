Deploy Kubernetes 1.20. & CentOS7 + GlusterFs + MetalLB + Nginx ingress controller in Vagrant
=============================================================================================


Description
--------------------------------
This project describe how to deploy Kubernetes using kubernetesSpray project + Gluster FS + MetalLB + Nginx ingress controller in Vagrant.
The purpose of this project is to deploy an infrastructure to learn and test in a environment similar to production.
We have create two forks, one for kubernetesSpray project and another one for GlusterFS, where we have fixed  some issues detected, we used  both forks to deploy kubernetes.

Requirements
--------------------------------
VirtualBox 6.1
Vagrant version: Installed Version: 2.2.6

    Vagrant  plugins:
        vagrant-hostmanager (1.8.9) (vagrant plugin install vagrant-hostmanager)
    Vagrant box list:
        centos/7 (virtualbox, 2004.01)

Vms Deployed:
-------------
* 6 Virtual Machines or physical nodes.
  * master-one.192.168.66.2.xip.io
    * role
      * ControlPlane
    * cpu: 4
    * memory:4000
    * disks:
      * sda 40 GiB
  * master-two.192.168.66.3.xip.io
    * role
      * ControlPlane
    * cpu: 4
    * memory:4000
    * disks:
      * sda 40 GiB
  * master-three.192.168.66.4.xip.io
    * role
      * ControlPlane
    * cpu: 4
    * memory:4000
    * disks:
      * sda 40 GiB
  * worker-one.192.168.66.5.xip.io
    * role
      * Compute node
      * GlusterFS
    * cpu: 4
    * memory:3000
    * disks:
      * sda 40 GiB
      * sdb 40 GiB
  * worker-two.192.168.66.6.xip.io
    * role
      * Compute node
      * GlusterFS
    * cpu: 4
    * memory:3000
    * disks:
      * sda 40 GiB
      * sdb 40 GiB
  * worker-three.192.168.66.7.xip.io
    * role
      * Compute node
      * GlusterFS
    * cpu: 4
    * memory:3000
    * disks:
      * sda 40 GiB
      * sdb 40 GiB
  * cicd.192.168.66.8.xip.io (Optional not deployed by default)
    * role
      * Cicd Jenkins
    * cpu: 4
    * memory:1000
    * disks:
      * sda 40 GiB

Annotations:
-----------
* Calico as Network: calico-rr
* GlusterFS as Storage Solution

Note:

* All the hostnames must be resolved by a DNS or set hostnames in the /etc/hosts of all the VMs. We will use xip.io as the hostname which will works as a DNS.

Plus CICD jenkins VMs:
-----------------------
As this is a Lab for learning and testing, it allows you to deploy a VMs with Jenkins installed. If you want to deploy the Vm with Jenkins, just change the value (deploy_cicd_vm: 'false') to true in the  file  "ansible/inventories/vagrant_local/group_vars/all.yaml" and lunch the ansible playbooks/installcicd.yaml during the installation guide.


Guide Steps:
-----------

a) Install K8s kubernetesSpray (Time 30min)

b) Deploy GlusterFS in Kubernetes (Time 10min)

c) Deploy MetalLB (Time 2min)

d) Deploy IngressController (Time 2min)

e) Install jenkins in CICD node (Time 10min)



a) Install K8s kubernetesSpray:
===============================

* Clone the project and create the infrastructure:
-------------------------------------------------

```
git clone https://github.com/vass-engineering/Lab-kubernetesSpray-v1.20.2.git

cd Lab-kubernetesSpray-v1.20.2/vagrant/

vagrant up
```


* Prepare the node bastion:
------------------------------

Login in the bastion, in our case master-one.192.168.66.2.xip.io will be the bastion:

```
vagrant ssh master-one-k8s
sudo su
export PATH=$PATH:/usr/local/bin/
```

Launch the next ansible playbook to prepare the bastion:

```
cd /root/kubernetesSpray-v1.20.2-glusterfs/InstallationOnVagrant/ansible
ansible-playbook  -i inventories/vagrant_local/bastion playbooks/preparebastion.yaml
```


* Prepare the rest of nodes:
--------------------------

```
ansible-playbook  -i /root/kubernetes_installation/inventory/mycluster/inventory.ini playbooks/preparationnodes.yaml
```


* Start kubernetes installation:
------------------------------

```
cd /root/kubernetes_installation
sudo pip3 install -r requirements.txt
ansible-playbook -i inventory/mycluster/inventory.ini  cluster.yml
```

Details of the successfully installation:

![alt text](https://github.com/vass-engineering/Lab-kubernetesSpray-v1.20.2/blob/master/img/InstallationAnsible.jpg)

* Check nodes status:
---------------------

```
[root@master-one deploy]# kubectl get nodes
NAME                               STATUS   ROLES                  AGE     VERSION
master-one.192.168.66.2.xip.io     Ready    control-plane,master   9m41s   v1.20.2
master-three.192.168.66.4.xip.io   Ready    control-plane,master   8m56s   v1.20.2
master-two.192.168.66.3.xip.io     Ready    control-plane,master   9m8s    v1.20.2
worker-one.192.168.66.5.xip.io     Ready    <none>                 7m56s   v1.20.2
worker-three.192.168.66.7.xip.io   Ready    <none>                 7m54s   v1.20.2
worker-two.192.168.66.6.xip.io     Ready    <none>                 7m54s   v1.20.2
```


* Optional, add "k" as alias for kubectl:
-----------------------------------
```
cd $home
vi ./.bashrc
alias k='kubectl'
```


b) Deploy GlusterFS in Kubernetes:
=================================

* Check configuration installation:
-----------------------------------

Check that all your nodes has glusterfs client installed:

```
cd /root/kubernetes_installation
ansible  -i inventory/mycluster/inventory.ini all  -a "glusterfs --version"
```
*Example exit: worker01.k8s.labs.vass.es | CHANGED | rc=0 >> glusterfs 7.9*

This installation processs create the topology file for glusterfs, if you have modified the inventory for Vagrant check the next file:

```
cd /root/glusterfs_installation/deploy/
cat topology.json
{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "worker-one.192.168.66.5.xip.io"
              ],
              "storage": [
                "192.168.66.5"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdb"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "worker-two.192.168.66.6.xip.io"
              ],
              "storage": [
                "192.168.66.6"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdb"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "worker-three.192.168.66.7.xip.io"
              ],
              "storage": [
                "192.168.66.7"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdb"
          ]
        }
      ]
    }
  ]
}
```

* Deploy glusterfs:
-------------------

Create a namespace for GlusterFs

```
kubectl create namespace glusterfs
```

Set the context for this namespaces
```
kubectl config set-context --current --namespace glusterfs
```


***Before to deploy decide the user-key variable and the admin-key variable***

*user-key: Secret string for general heketi users. heketi users have access to only Volume APIs. Used in dynamic provisioning. This is a required argument.*

*admin-key:Secret string for heketi admin user. heketi admin has access to all APIs and commands. This is a required argument.*


./gk-deploy -g \
 --user-key <MyUserStrongKey> \
 --admin-key <MyAdminStrongKey> \
 -l /tmp/heketi_deployment.log \
 -v topology.json

```
./gk-deploy -g --user-key kubernetes --admin-key kubernetesadmin -l /tmp/heketi_deployment.log -v topology.json
...
Do you wish to proceed with deployment?

[Y]es, [N]o? [Default: Y]: Y
...
...
...Deployment complete!
```

Check the pods for GlusterFs:

```
kubectl get pods

NAME                      READY   STATUS    RESTARTS   AGE
glusterfs-8qcl8           1/1     Running   0          3m18s
glusterfs-9727c           1/1     Running   0          3m18s
glusterfs-mmrlm           1/1     Running   0          3m18s
heketi-55c58cf9bf-4xq7k   1/1     Running   0          20s

```


Check HEKETI status:

```
export HEKETI_CLI_SERVER=$(kubectl get svc/heketi --template 'http://{{.spec.clusterIP}}:{{(index .spec.ports 0).port}}')
echo $HEKETI_CLI_SERVER
curl $HEKETI_CLI_SERVER/hello

...Hello from Heketi
```

* Create a StorageClass:
-----------------------

Decode the ${ADMIN_KEY} used before:

SECRET_KEY=`echo -n "${ADMIN_KEY}" | base64`
```
SECRET_KEY=`echo -n "kubernetesadmin" | base64`
```

Create a secret in order to access to heketi from the StorageClass:

```
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: heketi-secret
  namespace: default
data:
  # base64 encoded password. E.g.: echo -n "mypassword" | base64
  key: ${SECRET_KEY}
type: kubernetes.io/glusterfs
EOF

...
...
...
secret/heketi-secret created
```

Set HEKETI_CLI_SERVER variable before to create the StorageClass:

```
export HEKETI_CLI_SERVER=$(kubectl get svc/heketi --template 'http://{{.spec.clusterIP}}:{{(index .spec.ports 0).port}}')

echo $HEKETI_CLI_SERVER
...
http://10.233.60.171:8080
```
Create the StorageClass:

```
cat << EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterfs-storage
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "${HEKETI_CLI_SERVER}"
  restuser: "admin"
  secretNamespace: "default"
  secretName: "heketi-secret"
  volumetype: "replicate:3"
EOF

```


* Configure heketi-client if you want to communicate with heketi(Optional):
-------------------------------------------------------------------------

Download heketi client:

```
mkdir -p /root/heketi-client
cd /root/heketi-client
yum install wget
curl -s https://api.github.com/repos/heketi/heketi/releases/latest   | grep browser_download_url   | grep linux.amd64   | cut -d '"' -f 4   | wget -qi -
for i in `ls | grep heketi | grep .tar.gz`; do tar xvf $i; done
cd heketi/
cp heketi-cli /usr/sbin
heketi-cli --version
  heketi-cli v10.2.0
```

Now you can communicate with your glsuter:

heketi-cli cluster list --user admin --secret <$ADMIN_KEY>

```
heketi-cli cluster list --user admin --secret kubernetesadmin

Clusters:
Id:b6aea255961a90ddc2c720e7466e224f [file][block]


heketi-cli cluster info  b6aea255961a90ddc2c720e7466e224f --user admin --secret kubernetesadmin
Cluster id: b6aea255961a90ddc2c720e7466e224f
Nodes:
5ca1630d7f0fc21685ca44c7961c4d3d
6ecaab134daa9af3604cfb50428ab302
f4dc9b76cf31fa9600457c97cdc251a6
Volumes:
a32c10d23f91ce94a991e6b15caa12c2
Block: true

File: true


heketi-cli topology info --user admin --secret kubernetesadmin

Cluster Id: b6aea255961a90ddc2c720e7466e224f

    File:  true
    Block: true

    Volumes:

        Name: heketidbstorage
        Size: 2
        Id: a32c10d23f91ce94a991e6b15caa12c2
        Cluster Id: b6aea255961a90ddc2c720e7466e224f
        Mount: 10.0.5.34:heketidbstorage
        Mount Options: backup-volfile-servers=10.0.5.36,10.0.5.35
        Durability Type: replicate
        Replica: 3
        Snapshot: Disabled
```


* Configure StorageClass glusterfs-storage as your default StorageClass:
----------------------------------------------------------------------


Check the name of your storageclass:

```
kubectl get StorageClass
NAME                PROVISIONER               AGE
glusterfs-storage   kubernetes.io/glusterfs   10m
```

Patch the StorageClass as the default StorageClass:

*kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'*

```
kubectl patch storageclass glusterfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

...
...
...
storageclass.storage.k8s.io/glusterfs-storage patched
```


* Test your glusterfs Creating a pvc:
-----------------------------------

Create the pvc:

```
cat << EOF | kubectl apply -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: testglusterfs
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 250Mi
  storageClassName: glusterfs-storage
EOF
```

Check that the pvc bound a pv:

```
kubectl get pvc
...
...
...
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
testglusterfs   Bound    pvc-a7d23a03-c3b7-45cc-adc1-9974a68982c6   1Gi        RWX            glusterfs-storage   5d1h


kubectl get pv
glusterfs-storage            3d22h
pvc-a7d23a03-c3b7-45cc-adc1-9974a68982c6   1Gi        RWX            Delete           Bound    default/testglusterfs
```

c) Deploy MetalLB:
===============

Source of information: https://metallb.universe.tf/installation/

* Configure K8s for MetalLB:
----------------------------

```
kubectl edit configmap -n kube-system kube-proxy
```
and set:

```
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

* Install  MetalLB:
----------------------------

To install MetalLB, apply the manifest:

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml

# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

MetalLB remains idle until configured. This is accomplished by creating and deploying a configmap into the same namespace (metallb-system) as the deployment.

```
cd /tmp/MetalLB/
kubectl  create -f configlbVagrant.yaml
```

d) Deploy IngressController:
=========================

Source of information: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/


* Install helm3:
----------------

```
mkdir /tmp/helm3 && cd /tmp/helm3
wget https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz
tar -xvf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/sbin/helm
helm version
  version.BuildInfo{Version:"v3.5.2", GitCommit:"167aac70832d3a384f65f9745335e9fb40169dc2", GitTreeState:"dirty", GoVersion:"go1.15.7"}
```

* Add helm nginx-stable repository:
----------------------------------

```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

kubectl create ns ingresscontroller
kubectl config set-context --current --namespace ingresscontroller

helm install my-release nginx-stable/nginx-ingress

NAME: my-release
LAST DEPLOYED: Tue Feb 16 23:21:30 2021
NAMESPACE: ingresscontroller
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NGINX Ingress Controller has been installed.

```

* Check the IP for External-IP:
----------------------------------
MetalLB will gives an IP of the range defined during the installation. This will be the IP that you can use for the  Ingress objects.

```
kubectl get svc
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
my-release-nginx-ingress   LoadBalancer   10.233.37.103   192.168.66.80   80:30265/TCP,443:30233/TCP   7m50s
```

EXTERNAL-IP > 192.168.66.80


* Example Ingress:
----------------------------------

Now you can create ingress objects to use.

```
apiVersion: "networking.k8s.io/v1"
kind: "Ingress"
metadata:
  name: "example-ingress-minio"
spec:
  ingressClassName: "nginx"
  rules:
  - host: "minio.192.168.66.80.xip.io"
    http:
      paths:
      - path: "/"
        pathType: "Prefix"
        backend:
          service:
            name: minio-1613499518
            port:
              number: 9000
```


e) Install jenkins in CICD node:
===============================

Optional: Just if you change in the file ansible/inventories/vagrant_local/group_vars/all.yaml the value of  "deploy_cicd_vm: 'true')":
It will deploy jenkins in the VM "cicd.192.168.66.8.xip.io".

```
vagrant ssh master-one-k8s
sudo su
export PATH=$PATH:/usr/local/bin/
 ansible-playbook  -i /root/kubernetes_installation/inventory/mycluster/inventorycicd.ini playbooks/installcicd.yaml
```
