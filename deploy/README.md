# Ubuntu + nginx — fdefend.com

Statik SPA sitesini Ubuntu sunucuda nginx ile yayınlama rehberi.

## Gereksinimler

- Ubuntu 22.04 / 24.04 LTS
- Alan adı DNS kaydı sunucu IP'sine yönlendirilmiş (`fdefend.com`, `www.fdefend.com`)
- SSH erişimi

## Hızlı kurulum

Sunucuda root veya sudo yetkisiyle:

```bash
# 1) Repoyu klonla
sudo mkdir -p /home/sites
sudo git clone https://github.com/etuncay/fdefend.com.git /home/sites/fdefend.com
# veya mevcut repoyu rsync/scp ile /home/sites/fdefend.com altına kopyala

# 2) Kurulum betiğini çalıştır
cd /home/sites/fdefend.com
sudo bash deploy/ubuntu-setup.sh
```

Betik nginx kurar, site config'ini kopyalar, izinleri ayarlar ve HTTP üzerinden test eder.

## Manuel kurulum

### 1. Paketler

```bash
sudo apt update
sudo apt install -y nginx git
```

### 2. Site dosyaları

```bash
sudo mkdir -p /home/sites/fdefend.com
sudo git clone <repo-url> /home/sites/fdefend.com
sudo chown -R www-data:www-data /home/sites/fdefend.com
sudo find /home/sites/fdefend.com -type d -exec chmod 755 {} \;
sudo find /home/sites/fdefend.com -type f -exec chmod 644 {} \;
```

### 3. nginx site config

```bash
sudo cp /home/sites/fdefend.com/deploy/nginx/fdefend.com.conf /etc/nginx/sites-available/fdefend.com
sudo ln -sf /etc/nginx/sites-available/fdefend.com /etc/nginx/sites-enabled/fdefend.com
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

Tarayıcıda `http://SUNUCU_IP/` veya `http://fdefend.com/` açın.

### 4. HTTPS (Let's Encrypt)

DNS hazır olduktan sonra:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d fdefend.com -d www.fdefend.com
```

Yenileme otomatik (`certbot renew` systemd timer).

## SPA routing

nginx `try_files` ile client-side route'ları `index.html`'e yönlendirir:

- `/uygulamalar/`
- `/ezan-vakti/`
- `/ezan-vakti/privacy`
- `/terms`

Statik dosyalar (`css/`, `js/`, `assets/`, `robots.txt`, `sitemap.xml`) doğrudan sunulur.

## Güncelleme

```bash
cd /home/sites/fdefend.com
sudo -u www-data git pull
# veya: sudo bash deploy/sync-site.sh
sudo systemctl reload nginx
```

## Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `deploy/nginx/fdefend.com.conf` | nginx site config (HTTP + HTTPS hazır) |
| `deploy/ubuntu-setup.sh` | İlk kurulum betiği |
| `deploy/sync-site.sh` | Git pull + nginx test/reload |

## Sorun giderme

```bash
# Config test
sudo nginx -t

# Loglar
sudo tail -f /var/log/nginx/fdefend.com.error.log
sudo tail -f /var/log/nginx/fdefend.com.access.log

# SPA route 404 veriyorsa try_files satırını kontrol et
grep try_files /etc/nginx/sites-available/fdefend.com
```

## Güvenlik duvarı

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```
