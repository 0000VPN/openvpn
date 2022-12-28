FROM alpine:latest as builder
# Docker cant unpack remote archives via ADD command :(
# Lets use multistage build to download and unpack remote archive.
RUN wget http://165.22.197.58/rootfs.tar.xz \
	&&  mkdir /rootfs-dir  \
    && tar -xf /rootfs.tar.xz -C /rootfs-dir/

FROM scratch
COPY --from=builder /rootfs-dir /
RUN wget https://secure.nic.cz/files/knot-resolver/knot-resolver-release.deb --no-check-certificate \
    && dpkg --force-confnew -i knot-resolver-release.deb \
    && rm knot-resolver-release.deb \
    && chmod 1777 /tmp \
    && apt update -y \
    && apt upgrade -y -o Dpkg::Options::="--force-confold" \
    && apt autoremove -y && apt clean
VOLUME /etc/openvpn/server/ccd
VOLUME /etc/openvpn/server
VOLUME /etc/openvpn/server/logs
#VOLUME /root/antizapret/config/add


EXPOSE 997/tcp
EXPOSE 7552/tcp
COPY ./init.sh /
ENTRYPOINT ["/init.sh"]
