#!/bin/bash

# تعریف مسیر فایل‌ها
ROUTE_FILE="/etc/V2bX/route.json"
SING_FILE="/etc/V2bX/sing_origin.json"
HY2CONFIG_FILE="/etc/V2bX/hy2config.yaml"
LOG_FILE="/root/v2bx_config_update.log"  # مسیر لاگر
FILES_CHANGED=0  # متغیری برای بررسی تغییرات

# بررسی و تنظیم مجوز فایل‌ها
check_permissions() {
    local file_path="$1"
    local required_permissions="-rwxr-xr-x"
    
    if [ -f "$file_path" ]; then
        current_permissions=$(stat -c "%A" "$file_path")
        if [ "$current_permissions" != "$required_permissions" ]; then
            echo "مجوز $file_path نادرست است. تنظیم مجوز..."
            chmod 755 "$file_path"  # تنظیم مجوز -rwxr-xr-x
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

# بررسی مجوز فایل‌ها
check_permissions "$ROUTE_FILE"
check_permissions "$SING_FILE"
check_permissions "$HY2CONFIG_FILE"

# محتوای جدید برای فایل route.json
NEW_ROUTE_JSON='{
    "domainStrategy": "AsIs",
    "rules": [
        {
            "type": "field",
            "outboundTag": "block",
            "ip": [
                "geoip.dat:private",
                "geoip.dat:ir"
            ]
        },
        {
            "domain": [
                "geosite.dat:google"
            ],
            "outboundTag": "IPv4_out",
            "type": "field"
        },
        {
            "type": "field",
            "outboundTag": "block",
            "domain": [
                "geosite.dat:ir"
            ]
        },
        {
            "type": "field",
            "outboundTag": "block",
            "domain": [
                "regexp:(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com",
                "regexp:(.+.|^)(360|so).(cn|com)",
                "regexp:(Subject|HELO|SMTP)",
                "regexp:(torrent|.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)",
                "regexp:(^.@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)",
                "regexp:(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)",
                "regexp:(..||)(dafahao|mingjinglive|botanwang|minghui|dongtaiwang|falunaz|epochtimes|ntdtv|falundafa|falungong|wujieliulan|zhengjian).(org|com|net)",
                "regexp:(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLLiveUD|bt_key)",
                "regexp:(.+.|^)(360).(cn|com|net)",
                "regexp:(.*.||)(guanjia.qq.com|qqpcmgr|QQPCMGR)",
                "regexp:(.*.||)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)",
                "regexp:(.*.||)(netvigator|torproject).(com|cn|net|org)",
                "regexp:(..||)(visa|mycard|gash|beanfun|bank).",
                "regexp:(.*.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|breakgfw|chengmingmag|jinpianwang|qi-gong|mhradio|edoors|renminbao|soundofhope|xizang-zhiye|bannedbook|ntdtv|12321|secretchina|dajiyuan|boxun|chinadigitaltimes|dwnews|huaglad|oneplusnews|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)",
                "regexp:(.*.||)(miaozhen|cnzz|talkingdata|umeng).(cn|com)",
                "regexp:(.*.||)(mycard).(com|tw)",
                "regexp:(.*.||)(gash).(com|tw)",
                "regexp:(.bank.)",
                "regexp:(.*.||)(pincong).(rocks)",
                "regexp:(.*.||)(taobao).(com)",
                "regexp:(.*.||)(laomoe|jiyou|ssss|lolicp|vv1234|0z|4321q|868123|ksweb|mm126).(com|cloud|fun|cn|gs|xyz|cc)",
                "regexp:(flows|miaoko).(pages).(dev)"
            ]
        },
        {
            "type": "field",
            "outboundTag": "block",
            "ip": [
                "127.0.0.1/32",
                "10.0.0.0/8",
                "fc00::/7",
                "fe80::/10",
                "172.16.0.0/12"
            ]
        },
        {
            "type": "field",
            "outboundTag": "block",
            "protocol": [
                "bittorrent"
            ]
        }
    ],
    "rule_set": [
        {
            "tag": "geoip.dat-ir",
            "type": "remote",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geoip.dat-ir.srs",
            "download_detour": "direct"
        },
        {
            "tag": "geosite.dat-ir",
            "type": "remote",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite.dat-ir.srs",
            "download_detour": "direct"
        }
    ]
}'

# محتوای جدید برای فایل sing_origin.json
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
        "rule_set": [
          "geosite.dat-ir"
        ],
        "outbound": "direct"
      },
      {
        "rule_set": [
          "geoip.dat-ir"
        ],
        "outbound": "direct"
      },
      {
        "domain_regex": [
          "(.*.||)(example-regex1|example-regex2).(com|net)"
        ],
        "outbound": "block"
      },
      {
        "outbound": "direct",
        "network": [
          "udp",
          "tcp"
        ]
      }
    ],
    "rule_set": [
      {
        "tag": "geoip.dat-ir",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geoip.dat-ir.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite.dat-ir",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite.dat-ir.srs",
        "download_detour": "direct"
      }
    ]
  },
  "experimental": {
    "cache_file": {
      "enabled": true
    }
  }
}'

# محتوای جدید برای فایل hy2config.yaml
NEW_HY2CONFIG_YAML='quic:
  initStreamReceiveWindow: 16777216
  maxStreamReceiveWindow: 33554432
  initConnReceiveWindow: 33554432
  maxConnReceiveWindow: 67108864
  maxIdleTimeout: 60s
  maxIncomingStreams: 2048
  disablePathMTUDiscovery: false
ignoreClientBandwidth: true
disableUDP: false
udpIdleTimeout: 120s
resolver:
  type: system
acl:
  inline:
    - direct(geosite.dat:ir)
    - reject(geosite.dat:blocked)
    - reject(geoip.dat:ir)
masquerade:
  type: 404'

# تابعی برای نوشتن لاگ
log_success() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - فایل $1 با موفقیت به روز شد" >> $LOG_FILE
}

# تابعی برای بررسی تغییر و به روز رسانی فایل‌ها
update_file_if_needed() {
    local file_path="$1"
    local new_content="$2"
    
    if ! diff <(echo "$new_content") "$file_path" >/dev/null; then
        echo "$new_content" > "$file_path"
        chmod 755 "$file_path"  # تنظیم مجوز -rwxr-xr-x
        log_success "$file_path"
        FILES_CHANGED=1  # فایل تغییر کرده است
    else
        echo "فایل $file_path نیازی به به‌روزرسانی ندارد."
    fi
}

# بررسی و به‌روزرسانی فایل‌ها
update_file_if_needed "$ROUTE_FILE" "$NEW_ROUTE_JSON"
update_file_if_needed "$SING_FILE" "$NEW_SING_ORIGIN_JSON"
update_file_if_needed "$HY2CONFIG_FILE" "$NEW_HY2CONFIG_YAML"

# اگر فایل‌ها تغییر کرده باشند، v2bx را restart کنید
if [ $FILES_CHANGED -eq 1 ]; then
    echo "فایل‌ها تغییر کردند. v2bx در حال راه‌اندازی مجدد است..."
    cd /root && v2bx restart
else
    echo "هیچ فایلی تغییر نکرده است. نیازی به راه‌اندازی مجدد نیست."
fi

echo "پیکربندی فایل‌ها بررسی و در صورت نیاز به‌روزرسانی شدند."
