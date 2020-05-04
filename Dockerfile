FROM archlinux
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel
RUN pacman -S --noconfirm openssh git
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel_nopasswd

# Install extra packages.
RUN pacman -S --noconfirm python3 rustup

# Install yay and peru from the AUR.
RUN useradd -m build
RUN gpasswd -a build wheel
USER build
RUN mkdir /tmp/yay && \
    cd /tmp/yay && \
    curl https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay-bin > PKGBUILD && \
    makepkg --syncdeps --install --noconfirm
RUN yay -S --noconfirm peru
USER root

# Install the stable Rust toolchain.
RUN rustup set profile minimal
RUN rustup install stable
