FROM nginx:alpine

# Run the static site as an unprivileged user.
RUN rm /etc/nginx/conf.d/default.conf \
    && printf '%s\n' \
      'server {' \
      '    listen 8080;' \
      '    listen [::]:8080;' \
      '    server_name _;' \
      '    root /usr/share/nginx/html;' \
      '    index index.html;' \
      '    location / {' \
      '        try_files $uri $uri/ =404;' \
      '    }' \
      '    location ~ /\\. {' \
      '        deny all;' \
      '    }' \
      '}' > /etc/nginx/conf.d/default.conf \
    && sed -i 's/listen       80;/listen       8080;/' /etc/nginx/nginx.conf \
    && chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

COPY --chown=nginx:nginx . /usr/share/nginx/html

USER nginx
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
