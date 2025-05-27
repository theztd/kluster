FROM quay.io/centos-bootc/centos-bootc:stream9 AS base

#LABEL org.osbuild.ostree.bootable=true

# EPEL pro extra nástroje (htop, jq, systemd-networkd)
RUN dnf install -y epel-release && \
    dnf install -y --setopt=install_weak_deps=False \
      systemd-networkd \
      systemd-resolved \
      openssh-server \
      tar \
      htop \
      haproxy \
      jq \
      ncdu \
      vim-minimal \
      curl && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/lib/dnf

# Enable systemd-networkd and disable NetworkManager
RUN systemctl enable systemd-networkd.service && \
    systemctl enable systemd-resolved.service && \
    systemctl mask NetworkManager.service && \
    systemctl mask NetworkManager-dispatcher.service

# Configure DHCP on eth0 (or any interface starting with en or eth)
RUN mkdir -p /etc/systemd/network && \
    echo '[Match]' > /etc/systemd/network/10-default.network && \
    echo 'Name=eth* en*' >> /etc/systemd/network/10-default.network && \
    echo '[Network]' >> /etc/systemd/network/10-default.network && \
    echo 'DHCP=yes' >> /etc/systemd/network/10-default.network

# Custom shell environment
COPY shared/99-custom_shell.sh /etc/profile.d/99-custom_shell.sh
COPY shared/virc /etc/virc

# Install helm (manual from GitHub)
RUN curl -sSL https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm*

# Install latest k0s
RUN curl -sSf https://get.k0s.sh | sh && \
    mkdir -p /var/lib/cni && \
    ln -s /var/lib/cni /opt/cni

# Install stern
RUN curl -kL -o /tmp/stern.tgz https://github.com/stern/stern/releases/download/v1.32.0/stern_1.32.0_linux_amd64.tar.gz && \
    tar -xzpf /tmp/stern.tgz -C /usr/local/bin/

# Mask unnecessary services to reduce attack surface
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


CMD ["/sbin/init"]
