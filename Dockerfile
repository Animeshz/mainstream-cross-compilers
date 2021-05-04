FROM --platform=amd64 debian:strech-slim

RUN \
# ==================================== Initial setup ====================================
#
build_deps=( \
    autoconf \
    automake \
    autopoint \
    bash \
    bison \
    bzip2 \
    flex \
    g++ \
    g++-multilib \
    gettext \
    git \
    gperf \
    intltool \
    libc6-dev-i386 \
    libgdk-pixbuf2.0-dev \
    libltdl-dev \
    libssl-dev \
    libtool-bin \
    libxml-parser-perl \
    lzip \
    make \
    openssl \
    p7zip-full \
    patch \
    perl \
    python \
    ruby \
    sed \
    unzip \
    wget \
    xz-utils \
) && \
#
apt update && \
apt install $build_deps && \
#
mkdir -p /opt && \
#
#
# ==================================== Setup Windows compilers ====================================
#
cd /opt && \
git clone https://github.com/mxe/mxe.git && \
cd mxe && \
git checkout 29bdf5b0692e1032eb1aa648f39a22f923a3d29d && \
#
echo "" >> settings.mk && \
sed -i \
    -e "$ a MXE_TARGETS := x86_64-w64-mingw32.shared i686-w64-mingw32.shared" \
    -e "$ a MXE_USE_CCACHE :=" \
    -e "$ a MXE_PLUGIN_DIRS := plugins/gcc10" \
    -e "$ a LOCAL_PKG_LIST := cc cmake" \
    -e "$ a .DEFAULT local-pkg-list:" \
    -e "$ a local-pkg-list: \$(LOCAL_PKG_LIST)" \
    -e "/^$/d" \
    settings.mk && \
#
make JOBS=$(nproc) && \
#
# remove everything except usr directory
ls | grep -v usr | xargs rm -rf && \
#
#
# # ==================================== Setup Linux compilers ====================================
apt install gcc g++ cmake && \
#
#
# ==================================== Cleanup ====================================
#
apt --purge autoremove $build_deps && \
apt clean