#!/bin/bash

FILES=(
  "/etc/V2bX/route.json"
  "/etc/V2bX/sing_origin.json"
  "/etc/V2bX/hy2config.yaml"
)

LOG_FILE="/root/v2bx_config_update.log"
FILES_CHANGED=0

replace_patterns() {
  sed -i \
    -e 's/geoip:cn/geoip.dat:ir/g' \
    -e 's/geosite:cn/geosite.dat:ir/g' \
    -e 's/geosite:google/geosite.dat:google/g' "$1"
}

log_update() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - فایل $1 به‌روزرسانی شد." >> "$LOG_FILE"
}

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    if grep -Eq 'geoip:cn|geosite:cn|geosite:google' "$file"; then
      replace_patterns "$file"
      log_update "$file"
      FILES_CHANGED=1
    fi
  fi
done

if [ $FILES_CHANGED -eq 1 ]; then
  echo "فایل‌ها تغییر کردند. راه‌اندازی مجدد v2bx..."
  cd /root && v2bx restart
else
  echo "تغییری در فایل‌ها رخ نداد."
fi
