FROM centos:7 as build
LABEL maintainer="David Chidell (dchidell@cisco.com)"

FROM build as webproc
ENV WEBPROC_VERSION 0.3.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build

RUN yum -y install epel-release && yum -y install ocserv &&  yum -y install openssl && yum clean all
RUN mkdir /certs \
    && cd /certs \
    && openssl rand -base64 48 > passphrase.txt \
    && openssl genrsa -aes128 -passout file:passphrase.txt -out server.key 2048 \
    && openssl req -new -passin file:passphrase.txt -key server.key -out server.csr -subj "/C=GB/O=VPN Host/OU=Docker VPN/CN=*.vpn.local" \
    && cp server.key server.key.org \
    && openssl rsa -in server.key.org -passin file:passphrase.txt -out server.key \
    && openssl x509 -req -days 36500 -in server.csr -signkey server.key -out server.crt
 
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
COPY users.conf /users.conf
COPY vpn.conf /vpn.conf 
COPY vpn-init.sh /vpn-init.sh
COPY client_profile.xml /client_profile.xml
COPY README.md /README.md
RUN chmod a+x /vpn-init.sh
ENTRYPOINT ["webproc","--on-exit","restart","-c","/README.md","-c","/users.conf","-c","/vpn.conf","-c","/vpn-init.sh","-c","/client_profile.xml","-c","/certs/server.crt","-c","/certs/server.key","-c","/certs/server.key.org","--","/vpn-init.sh","ocserv", "-c", "/vpn.conf", "-f","-d","4"]
EXPOSE 443 443/udp 8080
