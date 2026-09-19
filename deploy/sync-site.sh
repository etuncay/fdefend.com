#!/usr/bin/env bash
# Site güncelleme: git pull + nginx reload
set -euo pipefail

SITE_ROOT="/home/sites/fdefend.com"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Bu betik root veya sudo ile çalıştırılmalı."
  exit 1
fi

if [[ ! -d "${SITE_ROOT}/.git" ]]; then
  echo "HATA: ${SITE_ROOT}/.git yok. Manuel rsync kullanın."
  exit 1
fi

echo "==> Git pull..."
cd "${SITE_ROOT}"
sudo -u www-data git pull --ff-only

echo "==> İzinler..."
chown -R www-data:www-data "${SITE_ROOT}"

echo "==> nginx test + reload..."
nginx -t
systemctl reload nginx

echo "Güncelleme tamamlandı: $(date)"
