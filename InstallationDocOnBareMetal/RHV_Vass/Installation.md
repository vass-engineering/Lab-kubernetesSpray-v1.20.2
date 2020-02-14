Deploy Kubernetes 1.16. & CentOS7
=================================

Download the full project in the bastion machine
------------------------------------------------
```
cd /root

yum install git -y

git clone https://github.com/felix-centenera/baremetal_kubespray_kubernetes.git
```

Execute bastion.sh to install some requirements in the bastion
---------------------------------------------------------------
```
cd baremetal_kubespray_kubernetes/InstallationTools

./bastion.sh
```

Copy SSH key too all the nodes
------------------------------

```
for host in master01.k8s.labs.vass.es \
            master02.k8s.labs.vass.es \
            master03.k8s.labs.vass.es \
            worker01.k8s.labs.vass.es \
            worker02.k8s.labs.vass.es \
            worker03.k8s.labs.vass.es;\
            do ssh-copy-id $host; \
            done
```

Ansible to prepare the bastion
------------------------------
```
cd ../ansible/

```
pwd: /root/baremetal_kubespray_kubernetes/ansible

```
ansible-playbook  -i inventories/rhvVass/bastion playbooks/preparebastion.yaml
```

Ansible to prepare the nodes
------------------------------
```
ansible-playbook  -i /root/kubernetes_installation/inventory/mycluster/inventory.ini playbooks/preparationnodes.yaml
```

Start kubernetes installation
------------------------------
```
cd /root/kubernetes_installation
pip install --user -r requirements.txt
ansible-playbook -i inventory/mycluster/inventory.ini  cluster.yml
```
Prepare dashboard:
------------------------------
```
 kubectl cluster-info
  156  kubectl create serviceaccount dashboard-admin-sa
  157  kubectl create clusterrolebinding dashboard-admin-sa
  158  kubectl create clusterrolebinding dashboard-admin-sa  --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
  159  kubectl get secrets
  160  kubectl describe secret dashboard-admin-sa-token-svhm2
```
 ansible  -i inventory/mycluster/inventory.ini all  -a "lsblk"

master01.k8s.labs.vass.es | CHANGED | rc=0 >>
NAME            MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda               8:0    0  40G  0 disk
├─sda1            8:1    0   1G  0 part /boot
└─sda2            8:2    0  39G  0 part
  ├─centos-root 253:0    0  36G  0 lvm  /
  └─centos-swap 253:1    0   3G  0 lvm  
sr0              11:0    1   1G  0 rom  

master02.k8s.labs.vass.es | CHANGED | rc=0 >>
NAME            MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda               8:0    0  40G  0 disk
├─sda1            8:1    0   1G  0 part /boot
└─sda2            8:2    0  39G  0 part
  ├─centos-root 253:0    0  36G  0 lvm  /
  └─centos-swap 253:1    0   3G  0 lvm  
sr0              11:0    1   1G  0 rom  

master03.k8s.labs.vass.es | CHANGED | rc=0 >>
NAME            MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda               8:0    0  40G  0 disk
├─sda1            8:1    0   1G  0 part /boot
└─sda2            8:2    0  39G  0 part
  ├─centos-root 253:0    0  36G  0 lvm  /
  └─centos-swap 253:1    0   3G  0 lvm  
sr0              11:0    1   1G  0 rom  

worker01.k8s.labs.vass.es | CHANGED | rc=0 >>
NAME            MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda               8:0    0  40G  0 disk
├─sda1            8:1    0   1G  0 part /boot
└─sda2            8:2    0  39G  0 part
  ├─centos-root 253:0    0  36G  0 lvm  /
  └─centos-swap 253:1    0   3G  0 lvm  
sdb               8:16   0  40G  0 disk
sr0              11:0    1   1G  0 rom  

worker02.k8s.labs.vass.es | CHANGED | rc=0 >>
NAME            MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda               8:0    0  40G  0 disk
├─sda1            8:1    0   1G  0 part /boot
└─sda2            8:2    0  39G  0 part
  ├─centos-root 253:0    0  35G  0 lvm  /
  └─centos-swap 253:1    0   4G  0 lvm  
sdb               8:16   0  40G  0 disk
sr0              11:0    1   1G  0 rom  

worker03.k8s.labs.vass.es | CHANGED | rc=0 >>
NAME            MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda               8:0    0  40G  0 disk
├─sda1            8:1    0   1G  0 part /boot
└─sda2            8:2    0  39G  0 part
  ├─centos-root 253:0    0  36G  0 lvm  /
  └─centos-swap 253:1    0   3G  0 lvm  
sdb               8:16   0  40G  0 disk
sr0              11:0    1   1G  0 rom  

ansible  -i inventory/mycluster/inventory.ini all  -a "glusterfs --version"
worker01.k8s.labs.vass.es | CHANGED | rc=0 >>
glusterfs 7.2


cd /root/glusterfs_installation/deploy/
cp topology.json.sample topology.json
vi topology.json
cat topology.json
{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "worker01.k8s.labs.vass.es"
              ],
              "storage": [
                "10.0.5.34"
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
                "worker02.k8s.labs.vass.es"
              ],
              "storage": [
                "10.0.5.35"
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
                "worker03.k8s.labs.vass.es"
              ],
              "storage": [
                "10.0.5.36"
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


./gk-deploy -g \
 --user-key MyUserStrongKey \
 --admin-key MyAdminStrongKey \
 -l /tmp/heketi_deployment.log \
 -v topology.json



./gk-deploy -g \
 --user-key MyUserStrongKey \
 --admin-key MyAdminStrongKey \
 -l /tmp/heketi_deployment.log \
 -v topology.json

user-key: Secret string for general heketi users. heketi users have access
              to only Volume APIs. Used in dynamic provisioning. This is a
              required argument.
admin-key:Secret string for heketi admin user. heketi admin has access to
              all APIs and commands. This is a required argument.


./gk-deploy -g --user-key kubernetes --admin-key kubernetesadmin -l /tmp/heketi_deployment.log -v topology.json


For dynamic provisioning, create a StorageClass similar to this:

---
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: glusterfs-storage
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://10.233.112.7:8080"
  restuser: "user"
  restuserkey: "kubernetes"


Deployment complete!



# step 6. 创建storageclass，来自动为pvc创建pv

./gk-deploy -g --user-key kubernetes --admin-key kubernetesadmin -l /tmp/heketi_deployment.log -v topology.json
SECRET_KEY=`echo -n "${ADMIN_KEY}" | base64`
SECRET_KEY=`echo -n "kubernetesadmin" | base64`

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

secret/heketi-secret created


export HEKETI_CLI_SERVER=$(kubectl get svc/heketi --template 'http://{{.spec.clusterIP}}:{{(index .spec.ports 0).port}}')
echo $HEKETI_CLI_SERVER
curl $HEKETI_CLI_SERVER/hello

Hello from Heketi

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


mkdir -p /root/heketi-client
cd /root/heketi-client
 yum install wget
curl -s https://api.github.com/repos/heketi/heketi/releases/latest   | grep browser_download_url   | grep linux.amd64   | cut -d '"' -f 4   | wget -qi -

for i in `ls | grep heketi | grep .tar.gz`; do tar xvf $i; done

cd heketi/
cp ./heketi/heketi-cli /usr/local/bi
 heketi-cli --version
heketi-cli v9.0.0

export HEKETI_CLI_SERVER=$(kubectl get svc/heketi --template 'http://{{.spec.clusterIP}}:{{(index .spec.ports 0).port}}')
echo $HEKETI_CLI_SERVER
http://10.233.60.171:8080

heketi-cli cluster list --user admin --secret kubernetesadmin

Clusters:
Id:b6aea255961a90ddc2c720e7466e224f [file][block]


heketi-cli cluster info  b6aea255961a90ddc2c720e7466e224f
Cluster id: b6aea255961a90ddc2c720e7466e224f
Nodes:
5ca1630d7f0fc21685ca44c7961c4d3d
6ecaab134daa9af3604cfb50428ab302
f4dc9b76cf31fa9600457c97cdc251a6
Volumes:
a32c10d23f91ce94a991e6b15caa12c2
Block: true

File: true



heketi-cli topology info

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



k get StorageClass
NAME                PROVISIONER               AGE
glusterfs-storage   kubernetes.io/glusterfs   10m

kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl patch storageclass glusterfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

storageclass.storage.k8s.io/glusterfs-storage patched



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
