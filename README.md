**This is not production ready and proofed solution!!!**


# Kubernetes 2 cluster (slim)


Try to make k8s clustering as easy as possible and design solution for companies / startups with small or no platform engineering. This is 3 layer platform demo following git-ops guidelines.

Components:
 - fedora core with rpm-ostree
 - k0s
 - haproxy



## Design

TODO




## Install


### Install OS

Start os you want on the VM and install podman, than just run:
```bash
podman run --rm --privileged -v /dev:/dev -v /var/lib/containers:/var/lib/containers -v /:/target \
             --pid=host --security-opt label=type:unconfined_t \
             ghcr.io/theztd/kluster:amd64 \
             bootc install to-existing-root --root-ssh-authorized-keys /target/root/.ssh/authorized_keys

```

than restart the VM and installation is done!


### Setup cluster

configure env/YOUR_ENV/inventory file and run setup playbook
```bash
ansible-playbook -i envs/hz1/inventory playbook/setup-cluster.yaml

```

After the first run, you have to generate join token on cp and store it as k0s_join_token variable (it is recommended to encrypt it via ansible-vault).
Than run the playbook again and cluster will be ready.

```bash
# Generate token on cp-1 node
cp-1: ~ > k0s token create --role worker --expiry 10h
```



## 2nd day operations (manage)

### Update running OS

```bash
bootc upgrade
reboot

```

### Create new user

```bash
# create new user
# add him to group system:masters
# generate client config file
k0s kubeconfig create --groups "system:masters" new-user > config.yaml

# add user to another roles
k create clusterrolebinding marek --clusterrole=cluster-admin --user=marek

```

## Debug with an aditional tools

```bash
bootc usr-overlay
dnf install strace nmap tcpdump 

```

After os reboot everything will be at state before this installation.