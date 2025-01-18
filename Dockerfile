FROM debian:11-slim

ENV TZ="Europe/Prague"

RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends curl ca-certificates postgresql-13 \
    postgresql-contrib-13 postgresql-client-common wget apt-transport-https gnupg supervisor expect xdg-utils

RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
RUN echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends temurin-11-jre
#RUN wget -O- https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
#RUN echo "deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb bullseye main" | tee /etc/apt/sources.list.d/adoptopenjdk.list
#RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends adoptopenjdk-8-hotspot adoptopenjdk-8-hotspot-jre

RUN apt-get install -y locales locales-all
RUN echo "cs_CZ.utf8 UTF-8" >> /etc/locale.gen
RUN locale-gen cs_CZ.utf8 && update-locale
ENV LC_ALL="cs_CZ.UTF-8"

# Download latest flexibee
RUN curl -o flexibee.deb "$(curl 'https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/' | egrep -o '(https:[^\"]+\.deb)' | grep -v 'client')"
#RUN curl -o flexibee.deb "$(curl 'https://www.flexibee.eu/podpora/stazeni-flexibee/stazeni-ekonomickeho-systemu-flexibee-linux/' | egrep -o '(https:[^\"]+\.deb)' | grep -v 'flexibee_202')"

# Or, optionally, you could comment downloading and copy local deb file
# COPY flexibee_2025.2.1_all.deb flexibee.deb

# Copy & run installation script
ENV DISABLE_DB=1
COPY install.exp install.exp
RUN chmod +x install.exp
RUN ./install.exp

# Clean
RUN rm install.exp flexibee.deb

# Entrypoint
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
