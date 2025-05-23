# Deploy-Analisis-Registros

curl ifconfig.me

```
puedes registrar un subdominio como miapp.duckdns.org y apuntarlo a tu IP pública 91.99.108.180.

sudo apt install nginx certbot python3-certbot-nginx -y

sudo nano /etc/nginx/sites-available/analisis

server {
    listen 80;
    server_name miapp.duckdns.org;

    location / {
        proxy_pass http://localhost:4200;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

sudo ln -s /etc/nginx/sites-available/miapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d miapp.duckdns.org

sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```
