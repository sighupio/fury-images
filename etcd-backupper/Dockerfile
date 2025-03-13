FROM alpine:3.21

RUN apk add etcd-ctl yq

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
