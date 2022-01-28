ARG NODE_VERSION
ARG ALPINE_VERSION=3.15

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

RUN apk update && \
    apk add git jq make

RUN npm update -g && \
    npm i -g gulp@4.0.2 embedme@1.22.0
