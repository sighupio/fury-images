ARG HELM

FROM alpine/helm:${HELM}

ENV HELM_HOME /root/.helm

RUN apk add --update --no-cache git curl bash
RUN helm plugin install --debug https://github.com/instrumenta/helm-conftest

WORKDIR "/chart"

CMD ["conftest", "."]
