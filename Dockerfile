FROM debian:buster

ARG LIBSRTP_VERSION=2.3.0
#v0.10.8
ARG JANUS_VERSION=c5013f8a5579c11bde3ecf3120aadd0afbb27031
ARG LIBNICE_VERSION=0.1.18
ARG LIBWEBSOCKETS_VERSION=v3.2.0

RUN apt-get update -y \
    && apt-get upgrade -y

RUN apt-get install -y \
    build-essential \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libini-config-dev \
    libcollection-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    gtk-doc-tools \
    autotools-dev \
    automake

RUN apt-get install -y \
    sudo \
    make \
    git \
    wget \
    doxygen \
    graphviz \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    python3-setuptools

RUN pip3 install wheel meson

RUN apt-get remove lua5.1 -y && \
    apt-get install -y lua5.3 liblua5.3-dev luarocks && \
    luarocks install luajson && \
    luarocks install ansicolors

RUN cd ~ && \
    git clone  https://gitlab.freedesktop.org/libnice/libnice && \
    cd libnice && \
    git checkout  ${LIBNICE_VERSION}  && \
    meson  --prefix=/usr build && \
    ninja -C build && \
    ninja -C build install


RUN cd ~ && \
    wget https://github.com/cisco/libsrtp/archive/v${LIBSRTP_VERSION}.tar.gz && \
    tar xfv v${LIBSRTP_VERSION}.tar.gz && \
    cd libsrtp-${LIBSRTP_VERSION} && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library && sudo make install

RUN cd ~ && \
    git clone --single-branch --branch $LIBWEBSOCKETS_VERSION  https://github.com/warmcat/libwebsockets.git && \
    cd libwebsockets && \
    mkdir build && \
    cd build && \
    cmake  -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
    make && \
    sudo make install

RUN cd ~ && \
    git clone https://github.com/sctplab/usrsctp && \
    cd usrsctp &&\
    ./bootstrap && \
    ./configure --prefix=/usr && make && sudo make install


#COPY . .

#RUN cd ~ && \
#    git clone https://github.com/meetecho/janus-gateway.git && \
#    cd janus-gateway && \
#    git checkout  ${JANUS_VERSION} && \
#    sh autogen.sh && \
#    ./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt --disable-docs --enable-plugin-lua && \
#    make && \
#    make install && \
#    make configs