FROM alpine:latest

RUN apk add --no-cache lua5.3

WORKDIR /app

COPY . .

CMD ["lua", "main.lua"]
