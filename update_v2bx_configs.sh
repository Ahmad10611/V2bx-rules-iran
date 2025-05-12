#!/bin/bash

# مسیر فایل‌های پیکربندی
ROUTE_FILE="/etc/V2bX/route.json"
SING_FILE="/etc/V2bX/sing_origin.json"
DNS_FILE="/etc/V2bX/dns.json"
HY2CONFIG_FILE="/etc/V2bX/hy2config.yaml"
LOG_FILE="/root/v2bx_config_update.log"
FILES_CHANGED=0 

# تابع بررسی و تنظیم مجوز فایل‌ها
check_permissions() {
    local file_path="$1"
    local required_permissions="-rwxr-xr-x"
    
    if [ -f "$file_path" ]; then
        current_permissions=$(stat -c "%A" "$file_path")
        if [ "$current_permissions" != "$required_permissions" ]; then
            echo "مجوز $file_path نادرست است. تنظیم مجوز..."
            chmod 755 "$file_path"
            echo "مجوز $file_path به $required_permissions تغییر یافت."
        else
            echo "مجوز $file_path صحیح است."
        fi
    else
        echo "فایل $file_path موجود نیست. ایجاد فایل جدید..."
        touch "$file_path"
        chmod 755 "$file_path"
        echo "فایل $file_path ایجاد شد و مجوز به $required_permissions تنظیم شد."
    fi
}

check_permissions "$ROUTE_FILE"
check_permissions "$SING_FILE"
check_permissions "$DNS_FILE"
check_permissions "$HY2CONFIG_FILE"

# محتوای اصلی برای route.json (بدون تغییر)
NEW_ROUTE_JSON='{
    "domainStrategy": "AsIs",
    "rules": [
        {
            "type": "field",
            "outboundTag": "block",
            "ip": [
                "geoip:private",
                "127.0.0.1/32",
                "10.0.0.0/8",
                "172.16.0.0/12",
                "fc00::/7",
                "fe80::/10"
            ]
        },
        {
            "type": "field",
            "outboundTag": "block",
            "domain": [
                "regexp:(torrent|BitTorrent|magnet:)"
            ]
        },
        {
            "type": "field",
            "outboundTag": "block",
            "protocol": [
                "bittorrent"
            ]
        }
    ]
}'

NEW_SING_ORIGIN_JSON='{
  "outbounds": [
    {
      "tag": "direct",
      "type": "direct",
      "domain_strategy": "prefer_ipv4"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "ip_is_private": true,
        "outbound": "block"
      },
      {
        "domain_regex": [
          "(torrent|BitTorrent|magnet:)"
        ],
        "outbound": "block"
      },
      {
        "outbound": "direct",
        "network": [
          "udp","tcp"
        ]
      }
    ]
  },
  "experimental": {
    "cache_file": {
      "enabled": true
    }
  }
}'

NEW_DNS_JSON='{
    "servers": [
        "1.1.1.1",
        "8.8.8.8",
        "localhost"
    ],
    "tag": "dns_inbound"
}'

NEW_HY2CONFIG_YAML='quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520
  maxIdleTimeout: 30s
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false
ignoreClientBandwidth: false
disableUDP: false
udpIdleTimeout: 60s
resolver:
  type: system
acl:
  inline:
    - direct(geosite:google)
masquerade:
  type: 404'

# تابع ثبت لاگ
log_success() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - فایل $1 با موفقیت به روز شد" >> $LOG_FILE
}

# تابع به‌روزرسانی فایل‌ها
update_file_if_needed() {
    local file_path="$1"
    local new_content="$2"
    
    if ! diff <(echo "$new_content") "$file_path" >/dev/null; then
        echo "$new_content" > "$file_path"
        chmod 755 "$file_path"
        log_success "$file_path"
        FILES_CHANGED=1
    else
        echo "فایل $file_path نیازی به به‌روزرسانی ندارد."
    fi
}

update_file_if_needed "$ROUTE_FILE" "$NEW_ROUTE_JSON"
update_file_if_needed "$SING_FILE" "$NEW_SING_ORIGIN_JSON"
update_file_if_needed "$DNS_FILE" "$NEW_DNS_JSON"
update_file_if_needed "$HY2CONFIG_FILE" "$NEW_HY2CONFIG_YAML"

if [ $FILES_CHANGED -eq 1 ]; then
    echo "فایل‌ها تغییر کردند. v2bx در حال راه‌اندازی مجدد است..."
    cd /root && v2bx restart
else
    echo "هیچ فایلی تغییر نکرده است. نیازی به راه‌اندازی مجدد نیست."
fi

echo "پیکربندی فایل‌ها بررسی و در صورت نیاز به‌روزرسانی شدند."
