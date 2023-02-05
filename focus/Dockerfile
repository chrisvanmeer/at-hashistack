FROM alpine
RUN apk add --update nodejs
WORKDIR /app
COPY server.js /app/server.js
EXPOSE 8080
CMD ["node", "server.js"]
