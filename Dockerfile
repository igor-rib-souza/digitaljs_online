FROM ubuntu:20.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

RUN apt-get update && \
    apt-get install -y curl build-essential git clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git \
    graphviz xdot pkg-config python3 libboost-system-dev \
    libboost-python-dev libboost-filesystem-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/YosysHQ/yosys.git yosys
RUN cd yosys && make -j$(nproc) && make install

FROM node

WORKDIR /app

RUN node -v

COPY --from=builder /usr/local/bin/yosys /usr/local/bin/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libffi.so.7 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtcl8.6.so /usr/lib/x86_64-linux-gnu/
COPY . /app

RUN npm install && \
    npm install pm2 -g

RUN node -v

EXPOSE 3000



CMD pm2-runtime start npm -- run dev