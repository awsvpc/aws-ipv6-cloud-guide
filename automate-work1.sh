mkdir .ssh/
chmod 700 .ssh
chmod 600 ~/.ssh/authorized_keys

## Root
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y yum-utils
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y upgrade
yum -y install docker-ce kubelet kubeadm kubectl

mkdir /etc/docker
echo '{ "storage-driver": "overlay2" }' > /etc/docker/daemon.json
DISK=nvme1n1
mkfs.xfs -n ftype=1 /dev/$DISK -f
echo "$DISK    /var/lib/docker    xfs    noatime,ssd    0 2" >> /etc/fstab
mount -a
systemctl enable docker ; systemctl start docker
systemctl start docker && systemctl enable docker
systemctl start kubelet && systemctl enable kubelet

sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sysctl -w net.ipv4.ip_forward=1 #master
sysctl --system
sed -i '/swap/d' /etc/fstab

--apiserver-advertise-address=

kubeadm init --apiserver-advertise-address= --pod-network-cidr=10.200.248.0/21 --apiserver-advertise-address=10.200.62.11

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f \
https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/etcd.yaml
kubectl apply -f \
https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/rbac.yaml
kubectl apply -f \
https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/calico.yaml

kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>


