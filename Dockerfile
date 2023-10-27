# syntax=docker.io/docker/dockerfile:1.5.2

FROM golang:1.21.3 as builder

RUN go install -tags 'extended' github.com/gohugoio/hugo@latest

COPY libs/liaosirui.com /apps/liaosirui.com
COPY libs/resume.liaosirui.com /apps/resume.liaosirui.com

WORKDIR /apps

RUN \
    true \
    && cd liaosirui.com && hugo mod get -u && hugo -D && cd .. \
    && cd resume.liaosirui.com && hugo mod get -u && hugo -D && cd .. \
    && true

FROM docker.io/openresty/openresty:1.21.4.2-1-buster-fat

COPY docker/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

COPY --from=builder \
    /apps/liaosirui.com/public \
    /usr/local/openresty/nginx/html/liaosirui.com
COPY --from=builder \
    /apps/resume.liaosirui.com/public \
    /usr/local/openresty/nginx/html/resume.liaosirui.com
