FROM nginx:1.13
RUN rm -f /etc/nginx/conf.d/*
RUN rm -f /usr/share/nginx/html/*

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./conf.d/* /etc/nginx/conf.d/
CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
