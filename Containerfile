FROM quay.io/centos-bootc/centos-bootc:stream9 AS base

LABEL org.osbuild.ostree.bootable=true

# Install minimal tools and oldschool network stack
RUN dnf install -y epel-release && \
    dnf install -y --setopt=install_weak_deps=False \
      initscripts \
      openssh-server \
      tar \
      htop \
      haproxy \
      vim-minimal \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf

# Install helm manually (not in CentOS repos)
RUN curl -sSL https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm*

# Custom shell tweaks
COPY shared/99-custom_shell.sh /etc/profile.d/99-custom_shell.sh
COPY shared/virc /etc/virc

# Install latest k0s
RUN curl -sSf https://get.k0s.sh | sh && \
    mkdir -p /var/lib/cni && \
    ln -s /var/lib/cni /opt/cni

# Install stern
RUN curl -kL -o /tmp/stern.tgz https://github.com/stern/stern/releases/download/v1.32.0/stern_1.32.0_linux_amd64.tar.gz && \
    tar -xzpf /tmp/stern.tgz -C /usr/local/bin/

# Force traditional eth0 name
RUN echo 'net.ifnames=0 biosdevname=0' > /etc/kernel/cmdline

# Add basic ifcfg config for DHCP on eth0
RUN mkdir -p /etc/sysconfig/network-scripts && \
    echo 'DEVICE=eth0' > /etc/sysconfig/network-scripts/ifcfg-eth0 && \
    echo 'BOOTPROTO=dhcp' >> /etc/sysconfig/network-scripts/ifcfg-eth0 && \
    echo 'ONBOOT=yes' >> /etc/sysconfig/network-scripts/ifcfg-eth0

# Enable basic networking
RUN systemctl enable network.service && \
    systemctl mask NetworkManager.service


# Mask unnecessary services to reduce surface
RUN systemctl mask \
      avahi-daemon.service \
      avahi-daemon.socket \
      bluetooth.service \
      systemd-homed.service \
      systemd-homed-activate.service \
      pcscd.socket \
      udisks2.service \
      irqbalance.service \
      mdmonitor.service \
      lvm2-monitor.service \
      lvm2-lvmpolld.socket \
      dm-event.socket \
      remote-cryptsetup.target \
      remote-fs.target \
      sssd.service \
      systemd-pstore.service \
      systemd-userdbd.socket

# Optional disables (not masked – easier to re-enable)
RUN systemctl disable \
      nfs-client.target \
      dnf-makecache.timer \
      rpmdb-migrate.service \
      rpmdb-rebuild.service

CMD ["/sbin/init"]
