FROM jitsi/base-java

ARG CHROME_RELEASE=latest
ARG CHROMEDRIVER_MAJOR_RELEASE=latest

RUN \
	apt-dpkg-wrap apt-get update \
	&& apt-dpkg-wrap apt-get install -y jibri \
	&& apt-cleanup

RUN \
	[ "${CHROME_RELEASE}" = "latest" ] \
	&& curl -4s https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-dpkg-wrap apt-get update \
	&& apt-dpkg-wrap apt-get install -y google-chrome-stable \
	&& apt-cleanup \
	|| true

RUN \
        [ "${CHROME_RELEASE}" != "latest" ] \
        && curl -4so /tmp/google-chrome-stable_${CHROME_RELEASE}_amd64.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_RELEASE}_amd64.deb \
	&& apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y /tmp/google-chrome-stable_${CHROME_RELEASE}_amd64.deb \
	&& apt-cleanup \
	|| true

RUN \
	[ "${CHROMEDRIVER_MAJOR_RELEASE}" = "latest" ] \
	&& CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" \
	|| CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_MAJOR_RELEASE})" \
	&& curl -4Ls https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip \
	| zcat >> /usr/bin/chromedriver \
	&& chmod +x /usr/bin/chromedriver \
	&& chromedriver --version

RUN \
        [ "$JITSI_RELEASE" = "unstable" ] \
        && apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jitsi-upload-integrations \
        && apt-cleanup \
        || true

COPY rootfs/ /

VOLUME /config

