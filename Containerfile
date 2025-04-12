FROM registry.gitlab.com/fedora/bootc/base-images/fedora-bootc-minimal:40-amd64 AS base

# Přidej balíčky přes DNF (nutné pro systemd prostředí)
RUN dnf install -y \
      htop \
      haproxy \
      vim-minimal \
    && dnf clean all

COPY shared/99-custom_shell.sh /etc/profile.d/99-custom_shell.sh
COPY shared/virc /etc/virc

# Install k0s
RUN curl -sSf https://get.k0s.sh | sh && \
   k0s kubectl completion bash > /etc/bash_completion.sh

# Install stern
RUN curl -kL -o /tmp/stern.tgz https://github.com/stern/stern/releases/download/v1.32.0/stern_1.32.0_linux_amd64.tar.gz && \
    tar -xzpf /tmp/stern.tgz -C /usr/local/bin/

CMD ["/sbin/init"]