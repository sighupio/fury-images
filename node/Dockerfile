ARG NODE_VERSION
ARG ALPINE_VERSION=3.18

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

RUN apk update && \
    apk add bash git jq make util-linux

RUN npm update -g && \
    npm i -g \
        @stoplight/spectral-cli@6.8.0 \
        embedme@1.22.1 \
        gulp@4.0.2 \
        jest@29.5.0 \
        jest-environment-jsdom@29.5.0
