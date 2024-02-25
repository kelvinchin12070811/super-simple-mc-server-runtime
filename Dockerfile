FROM eclipse-temurin:17

RUN apt-get update && \
    apt-get install -y supervisor ruby-full p7zip-full p7zip-rar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /app/minecraft
COPY ./src ./bin

EXPOSE 25565
ENV EULA=TRUE
ENV BACKUP_DURATION=30

CMD ["/usr/bin/supervisord"]
