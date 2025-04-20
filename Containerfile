FROM quay.io/fedora-testing/fedora-bootc:42-minimal AS base

# Install minimal set of tools
RUN dnf install -y --setopt=install_weak_deps=False \
      systemd-networkd \
      tar \
      htop \
      tar \
      haproxy \
      helm \
      vim-minimal && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/lib/dnf

# Switch from NetworkManager to systemd-networkd
# RUN systemctl enable systemd-networkd.service \
#     && systemctl enable systemd-resolved.service \
#     && systemctl mask NetworkManager.service \
#     && systemctl mask NetworkManager-dispatcher.service

COPY shared/99-custom_shell.sh /etc/profile.d/99-custom_shell.sh
COPY shared/virc /etc/virc

# Install latest k0s version
RUN curl -sSf https://get.k0s.sh | sh
RUN mkdir -p /var/lib/cni && \
    ln -s /var/lib/cni /opt/cni

# Install stern
RUN curl -kL -o /tmp/stern.tgz https://github.com/stern/stern/releases/download/v1.32.0/stern_1.32.0_linux_amd64.tar.gz && \
    tar -xzpf /tmp/stern.tgz -C /usr/local/bin/

# Disable and mask unnecessary services to reduce attack surface
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

# Optional disables (not masked – easy to re-enable later)
RUN systemctl disable \
      nfs-client.target \
      dnf-makecache.timer \
      rpmdb-migrate.service \
      rpmdb-rebuild.service

CMD ["/sbin/init"]