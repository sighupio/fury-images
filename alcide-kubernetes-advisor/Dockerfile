FROM alpine:3.10 as downloader
RUN wget https://alcide.blob.core.windows.net/generic/stable/linux/advisor
RUN chmod +x advisor && mv advisor /bin/kube-advisor

RUN addgroup -S sighup && adduser -S sighup -G sighup
USER sighup:sighup

