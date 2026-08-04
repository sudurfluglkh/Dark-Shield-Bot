FROM alpine:latest
COPY . /app
WORKDIR /app
CMD ["lua", "main.lua"]
