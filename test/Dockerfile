FROM nginx:1.21

RUN apt-get update -y && apt-get install -y git && \
  git clone --depth 1 https://github.com/togodx/togodx-app /app && \
  mv -f /app/build /root/public

ADD ./config/nginx.conf /etc/nginx/conf.d/default.conf

ADD ./config/config.json /root/public/config.json

ADD ./config/config-human/attributes.json /root/public/attributes.json
ADD ./config/config-human/backend.json /root/public/backend.json
ADD ./config/config-human/properties.json /root/public/properties.json
ADD ./config/config-human/templates.json /root/public/templates.json

RUN mkdir /root/logs
RUN chmod 755 -R /root

CMD ["nginx", "-g", "daemon off;"]
