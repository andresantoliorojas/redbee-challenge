FROM alpine:latest

RUN apk update && apk add --no-cache --update bash jq tzdata coreutils

ENV TZ=America/Argentina/Tucuman

COPY ./json_filter.sh ./input.json /app/

VOLUME [ "/data" ]