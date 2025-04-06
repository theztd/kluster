# Base image: Fedora 40 minimal OS
FROM registry.fedoraproject.org/fedora:40-minimal

# Labels to mark this as a bootable container image
LABEL containers.bootc="1" \
      ostree.bootable="1"

# Install base system packages and required tools (Fedora 40)
RUN dnf install -y \
      bootc \
      haproxy \
      kernel \
      systemd \
      grub2-pc \
      dracut && \
    dnf clean all && \
    # Install UEFI bootloader packages depending on architecture
    arch=$(uname -m); \
    if [ "$arch" = "x86_64" ]; then \
        dnf install -y grub2-efi-x64 shim-x64; \
    elif [ "$arch" = "aarch64" ]; then \
        dnf install -y grub2-efi-aa64 shim-aa64; \
    fi && \
    dnf clean all

# Generate initramfs for the installed kernel (force overwrite if exists)
RUN dracut --force --kver "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-core)"

# Run bootc lint to verify the image is bootc-compatible
RUN bootc container lint || (echo "Bootc lint failed" && exit 1)

# Set the default command to systemd (for completeness, when running the container)
CMD ["/sbin/init"]
