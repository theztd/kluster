**This is not production ready and proofed solution!!!**


# Kubernetes 2 cluster (slim)


Try to make k8s clustering as easy as possible and design solution for companies / startups with small or no platform engineering. This is 3 layer platform demo following git-ops guidelines.

Components:
 - fedora core with rpm-ostree
 - k0s
 - haproxy



## Design



## Install

```bash
podman run --rm --privileged -v /dev:/dev -v /var/lib/containers:/var/lib/containers -v /:/target \
             --pid=host --security-opt label=type:unconfined_t \
             registry.gitlab.com/fedora/bootc/base-images/fedora-bootc-minimal:40-amd64 \
             bootc install to-existing-root --root-ssh-authorized-keys /target/root/.ssh/authorized_keys

```


## 2nd day operations (manage)


