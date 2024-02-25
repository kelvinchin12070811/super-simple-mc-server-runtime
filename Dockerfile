FROM eclipse-temurin:17

WORKDIR /app/minecraft

RUN apt-get update && \
    apt-get install -y supervisor ruby-full p7zip-full p7zip-rar jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN MCRON_BIN_URL$(curl https://api.github.com/repos/Tiiffi/mcrcon/releases/latest | jq '.assets[] | select(.browser_download_url | endswith("x86-64.tar.gz")) | {name: .name, url: .browser_download_url}') && \
    curl -OL "$(echo $MCRCON_BIN_URL | jq .url -r)" && \
    7z x "$(echo $MCRCON_BIN_URL | jq '.name |= rtrimstr(".tar.gz") | .name' -r).tar.gz" && \
    7z x "$(echo $MCRCON_BIN_URL | jq '.name |= rtrimstr(".tar.gz") | .name' -r).tar" && \
    mkdir bin && \
    mv mcrcon ./bin/mcrcon && \
    chmod 755 mcrcon ./bin/mcrcon && \
    find . -type f -name '*.tar.gz' -delete && \
    find . -type f -name '*.tar' -delete


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./src ./bin

EXPOSE 25565
ENV EULA=TRUE
ENV BACKUP_DURATION=30

CMD ["/usr/bin/supervisord"]
