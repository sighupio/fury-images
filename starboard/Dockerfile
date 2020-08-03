ARG KUBECTL
FROM quay.io/sighup/kubectl:${KUBECTL}
ARG STARBOARD

RUN mkdir -p /temp && curl -L https://github.com/aquasecurity/starboard/releases/download/${STARBOARD}/starboard_linux_x86_64.tar.gz -o /temp/starboard_linux_x86_64.tar.gz && \
    tar -zxvf /temp/starboard_linux_x86_64.tar.gz -C /temp/ && \
    chmod +x /temp/starboard && \
    mv /temp/starboard /usr/local/bin/starboard && \
    rm -rf /temp/


ENTRYPOINT ["starboard"]
