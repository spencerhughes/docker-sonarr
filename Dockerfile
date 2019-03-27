FROM debian:stretch-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && \
	apt-get -qq upgrade && \
	apt-get -qq install \
		curl \
		gnupg2 \
		apt-utils \
		apt-transport-https \
	&& \
	apt-get -qq autoremove && \
	apt-get -qq clean

ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="master"
ARG SONARR_VERSION

RUN apt-get -qq update && \
	apt-get -qq install \
		jq \
	&& \
	if [ -z ${SONARR_VERSION+x} ]; then \
		SONARR_VERSION=$(curl -sX GET https://services.sonarr.tv/v1/download/${SONARR_BRANCH} | jq -r '.version'); \
	fi && \
	mkdir -p /opt/NzbDrone && \
	curl -o /tmp/sonarr.tar.gz -L "https://download.sonarr.tv/v2/${SONARR_BRANCH}/mono/NzbDrone.${SONARR_BRANCH}.${SONARR_VERSION}.mono.tar.gz" && \
	tar xzf /tmp/sonarr.tar.gz -C /opt/NzbDrone --strip-components=1 && \
	apt-get -qq purge \
		jq \
	&& \
	apt-get -qq clean && \
	rm -rf \
		/tmp/* \
		/var/tmp/*

WORKDIR /opt/NzbDrone

EXPOSE 8989

VOLUME /config /downloads /tv

CMD ["mono","--debug","NzbDrone.exe","-nobrowser","-data=/config"]