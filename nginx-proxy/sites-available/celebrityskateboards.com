# HTTP server configuration
server {
	listen 80;
	server_name celebrityskateboards.com www.celebrityskateboards.com;
	return 301 https://celebrityskateboards.com$request_uri;
}

# SSL Server Configuration
server {
        # SSL configuration
        #
        listen 443 ssl;
        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;
        ssl_certificate /etc/ssl_cert/celebrityskateboards.com/tls.crt;
        ssl_certificate_key /etc/ssl_cert/celebrityskateboards.com/tls.key;

        # Not hosted locally, so comment this out
        #root /var/www/celebrityskateboards.com;

        server_name celebrityskateboards.com www.celebrityskateboards.com;

        location / {
                proxy_pass http://celebrityskateboards-spa-angular-service:4200;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;

                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/Index.html $uri/ =404;
                #try_files $uri $uri/Index.html $uri/ /Index.html;
        }

        location /api/skatepark {
                proxy_pass http://skatepark-api-go-service:8080;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #       deny all;
        #}
}