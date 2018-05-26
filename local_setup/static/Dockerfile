FROM nginx
# EXPOSE 80

RUN apt-get update && apt-get install unzip wget curl -y
RUN wget -O /tmp/static.zip https://s3.amazonaws.com/infra-assessment/static.zip && unzip -d /usr/share/nginx/html/ /tmp/static.zip && rm /tmp/static.zip

COPY default.conf /etc/nginx/conf.d/default.conf
