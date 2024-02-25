FROM eclipse-temurin:17

WORKDIR /app/minecraft

RUN apt-get update && \
    apt-get install -y supervisor ruby-full p7zip-full p7zip-rar jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./src/dl_rcon.rb ./bin/dl_rcon.rb
RUN ruby /app/minecraft/bin/dl_rcon.rb

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./src ./bin

EXPOSE 25565
ENV EULA=TRUE
ENV ENABLE_BACKUP=FALSE

CMD ["/usr/bin/supervisord"]
