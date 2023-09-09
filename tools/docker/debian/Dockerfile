FROM i386/debian:bookworm-20230904-slim

ENV DEBIAN_FRONTEND noninteractive
ENV RESUME true
# Install

#  libc6-dev-amd64-i386-cross libc6-dev-amd64
RUN apt update && \
    apt --yes --no-install-recommends install \
    linux-image-686 grub2 systemd \
    libc6-dev make \
    unzip bzip2 xz-utils nano htop \
    strace file apt-file \
    dhcpcd5 \
    wget curl \
    net-tools git ca-certificates python3 \
    wmctrl xdotool cmake ninja-build clang-15 && \
    echo 'LANG="C.UTF-8"' > /etc/default/locale && \
    chsh -s /bin/bash && \
    echo "root:root" | chpasswd && \
    mkdir -p /etc/systemd/system/serial-getty@ttyS0.service.d/ && \
    systemctl enable serial-getty@ttyS0.service && \
    rm /lib/systemd/system/getty.target.wants/getty-static.service 

## --- From local ---
RUN git clone -b mob https://github.com/TinyCC/tinycc.git /root/tcc-0.9.27
COPY Yaksha_repo /root/Yaksha_repo
COPY pretend-zig /root/pretend-zig

## --- Rest of the stuff ----
RUN cd $HOME  && \ 
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-15 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-15 100 && \
    cd Yaksha_repo/compiler && mkdir cmake-build-release && cd cmake-build-release && \
    cmake -S .. -B . && \
    cmake --build . --config Release -j 4 && \
    apt --yes --no-install-recommends install gcc && \
    cd $HOME/tcc-0.9.27 && ./configure --cpu=i386 && make && make install && \
    cd $HOME && mkdir yaksha && \
    cd $HOME/yaksha && \
    mkdir $HOME/yaksha/bin && \
    chmod +x $HOME/pretend-zig && \
    mv $HOME/pretend-zig $HOME/yaksha/bin/zig && \
    cp $HOME/Yaksha_repo/compiler/bin/yaksha $HOME/yaksha/bin/yaksha && \
    cp $HOME/Yaksha_repo/compiler/bin/cmakecarpntr $HOME/yaksha/bin/carpntr && \
    cp -r $HOME/Yaksha_repo/compiler/runtime $HOME/yaksha/ && \
    cp -r $HOME/Yaksha_repo/compiler/libs $HOME/yaksha/ && \
    cp $HOME/Yaksha_repo/compiler/README.md $HOME/yaksha/ && \
    cd /root/ && rm /etc/motd /etc/issue && \
    systemctl disable apt-daily.timer && \
    systemctl disable apt-daily-upgrade.timer && \
    systemctl disable dhcpcd.service && \
    echo "tmpfs /tmp tmpfs nodev,nosuid 0 0" >> /etc/fstab


RUN rm -rf $HOME/Yaksha_repo
## -- clean up packages --

RUN apt --yes --no-install-recommends purge \
    make \
    unzip bzip2 xz-utils \
    strace file apt-file \
    dhcpcd5 \
    wget curl \
    net-tools git ca-certificates python3 \
    wmctrl xdotool cmake ninja-build clang-15 gcc
RUN apt --yes --no-install-recommends autoremove
RUN apt --yes --no-install-recommends install libc6-dev nano htop


COPY getty-noclear.conf getty-override.conf /etc/systemd/system/getty@tty1.service.d/
COPY getty-autologin-serial.conf /etc/systemd/system/serial-getty@ttyS0.service.d/
COPY logind.conf /etc/systemd/logind.conf
COPY boot-9p /etc/initramfs-tools/scripts/boot-9p

# this needs to be commented out in order to boot from hdd
RUN printf '%s\n' 9p 9pnet 9pnet_virtio virtio virtio_ring virtio_pci | tee -a /etc/initramfs-tools/modules && \
    echo 'BOOT=boot-9p' | tee -a /etc/initramfs-tools/initramfs.conf && \
    update-initramfs -u

COPY sample.yaka /root/sample.yaka
RUN cd /root && /root/yaksha/bin/yaksha build -RSN /root/sample.yaka && \
    rm /root/*.o && \
    rm /root/*.c && \
    rm -rf /root/tcc-0.9.27 &&\
    rm /root/sample && \
    apt --yes clean && \
    rm -r /var/lib/apt/lists/* && \
    rm -r /usr/share/doc/* && \
    rm -r /usr/share/man/* && \
    rm /var/log/*.log /var/log/lastlog /var/log/wtmp /var/log/apt/*.log /var/log/apt/*.xz /var/lib/dpkg/info/*

RUN     ln -s /usr/local/bin/tcc /bin/cc

COPY root-bashrc /root/.bashrc
COPY root-vimrc /root/.vimrc
COPY micro-settings.json /root/.config/micro/settings.json
COPY yaka-nanorc /usr/share/nano/yaksha.nanorc
COPY root-nanorc /root/.nanorc