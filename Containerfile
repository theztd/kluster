FROM registry.gitlab.com/fedora/bootc/base-images/fedora-bootc-minimal:40-amd64 AS base

# Přidej balíčky přes DNF (nutné pro systemd prostředí)
RUN dnf install -y \
      systemd-networkd \
      htop \
      haproxy \
      vim-minimal \
    && dnf clean all

# Switch from NetworkManager to systemd-networkd
RUN systemctl enable systemd-networkd.service \
    && systemctl enable systemd-resolved.service \
    && systemctl mask NetworkManager.service \
    && systemctl mask NetworkManager-dispatcher.service

COPY shared/99-custom_shell.sh /etc/profile.d/99-custom_shell.sh
COPY shared/virc /etc/virc

# Install k0s
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
      systemd-oomd.service \
      systemd-pstore.service \
      systemd-userdbd.socket \
      systemd-resolved.service

# Optional disables (not masked – easy to re-enable later)
RUN systemctl disable \
      getty@.service \
      nfs-client.target \
      dnf-makecache.timer \
      rpmdb-migrate.service \
      rpmdb-rebuild.service

CMD ["/sbin/init"]