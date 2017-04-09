FROM docker

WORKDIR /root

RUN apk --no-cache add nginx

RUN mkdir /run/nginx
COPY proxy.conf /etc/nginx/
COPY entrypoint.sh .

ENTRYPOINT ["sh", "entrypoint.sh"]

EXPOSE 2375
