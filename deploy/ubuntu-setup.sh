#!/usr/bin/env bash
# Ubuntu üzerinde fdefend.com nginx kurulumu
set -euo pipefail

SITE_ROOT="/home/sites/fdefend.com"
NGINX_AVAILABLE="/etc/nginx/sites-available/fdefend.com"
NGINX_ENABLED="/etc/nginx/sites-enabled/fdefend.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Bu betik root veya sudo ile çalıştırılmalı."
  exit 1
fi

echo "==> Paketler kuruluyor..."
apt update
apt install -y nginx git

echo "==> Site dizini hazırlanıyor: ${SITE_ROOT}"
mkdir -p "${SITE_ROOT}"

if [[ ! -f "${SITE_ROOT}/index.html" ]]; then
  if [[ -f "${REPO_ROOT}/index.html" ]]; then
    echo "    Repo dosyaları ${SITE_ROOT} altına kopyalanıyor..."
    rsync -a --delete \
      --exclude '.git' \
      "${REPO_ROOT}/" "${SITE_ROOT}/"
  else
    echo "HATA: ${SITE_ROOT}/index.html bulunamadı."
    echo "Önce repoyu klonlayın veya dosyaları ${SITE_ROOT} altına kopyalayın."
    exit 1
  fi
fi

echo "==> İzinler ayarlanıyor..."
chown -R www-data:www-data "${SITE_ROOT}"
find "${SITE_ROOT}" -type d -exec chmod 755 {} \;
find "${SITE_ROOT}" -type f -exec chmod 644 {} \;

echo "==> nginx site config kuruluyor..."
cp "${REPO_ROOT}/deploy/nginx/fdefend.com.conf" "${NGINX_AVAILABLE}"
ln -sf "${NGINX_AVAILABLE}" "${NGINX_ENABLED}"
rm -f /etc/nginx/sites-enabled/default

echo "==> nginx test..."
nginx -t

echo "==> nginx yeniden yükleniyor..."
systemctl enable nginx
systemctl reload nginx

echo ""
echo "Kurulum tamamlandı."
echo "  Site kökü : ${SITE_ROOT}"
echo "  Config    : ${NGINX_AVAILABLE}"
echo ""
echo "Test: http://$(hostname -I | awk '{print $1}')/"
echo ""
echo "HTTPS için (DNS hazırsa):"
echo "  apt install -y certbot python3-certbot-nginx"
echo "  certbot --nginx -d fdefend.com -d www.fdefend.com"
