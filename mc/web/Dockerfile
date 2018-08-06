FROM redelivre/mapasculturais as builder

FROM debian:jessie

RUN apt-get update && apt-get install -y \
    nginx

ADD nginx.conf /etc/nginx/
ADD site.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site
RUN rm /etc/nginx/sites-enabled/default

RUN echo "upstream php-upstream { server app_mc:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN usermod -u 1000 www-data
COPY --from=builder /var/www/html /var/www/html

CMD ["nginx"]

EXPOSE 80
EXPOSE 443
