FROM alpine:3.19

RUN apk add --no-cache \
    alpine-sdk \
    doas \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    linux-headers \
    curl \
    tar \
    openssl-dev \
    curl-dev \
    pcre2-dev \
    libxml2-dev \
    sqlite-dev

RUN adduser -D builder && \
    addgroup builder abuild && \
    addgroup builder wheel && \
    echo "permit nopass builder" > /etc/doas.d/builder.conf && \
    chmod 0400 /etc/doas.d/builder.conf

USER builder
WORKDIR /home/builder

CMD ["/bin/sh"]