FROM eclipse-temurin:17

WORKDIR /app/minecraft
COPY ./src .

EXPOSE 25565
ENV EULA=TRUE
CMD ["./startserver.sh"]
