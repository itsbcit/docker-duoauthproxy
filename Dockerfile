FROM bcit.io/almalinux:9-latest as build

# from https://duo.com/docs/authproxy-reference#installation
RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install  \
    gcc  \
    make \
    libffi-devel \
    perl \
    zlib-devel \
    diffutils

# modified from https://github.com/jumanjihouse/docker-duoauthproxy/
WORKDIR /src
ADD https://dl.duosecurity.com/duoauthproxy-6.6.0-src.tgz /src/
RUN tar xzf duoauthproxy-*-src.tgz \
 && cd duoauthproxy-*-src \
 && make \ 
 && useradd duo \
 && cd duoauthproxy-build \
 && ./install --install-dir=/opt/duoauthproxy --service-user=duo --log-group=duo --create-init-script=no

FROM bcit.io/almalinux:9-latest

LABEL maintainer="jesse@weisner.ca, chriswood.ca@gmail.com"
LABEL build_id="1769637436"

RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install  \
    openssl
COPY --from=build /opt/duoauthproxy/ /opt/duoauthproxy/
RUN useradd -s /sbin/nologin duo \
 && mkdir -p /opt/duoauthproxy/log \
 && chown -R duo:duo /opt/duoauthproxy/log

USER duo
CMD ["/opt/duoauthproxy/bin/authproxy"]
