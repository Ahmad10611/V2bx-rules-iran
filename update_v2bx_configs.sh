#!/bin/bash

ROUTE_FILE="/etc/V2bX/route.json"
SING_FILE="/etc/V2bX/sing_origin.json"
NEW_ROUTE_JSON='{...}' # محتوای فایل route.json جدید
NEW_SING_ORIGIN_JSON='{...}' # محتوای فایل sing_origin.json جدید

# بررسی و اصلاح مجوزها
check_permissions() {
    local file_path="$1"
    if [ "$(stat -c %a "$file_path")" != "755" ]; then
        chmod 755 "$file_path"
        echo "مجوز $file_path اصلاح شد."
    else
        echo "مجوز $file_path صحیح است."
    fi
}

# تابع بررسی تغییرات و به‌روزرسانی فایل‌ها
update_file_if_needed() {
    local file_path="$1"
    local new_content="$2"
    
    if [ "$(cat $file_path)" != "$new_content" ]; then
        echo "$new_content" > "$file_path"
        echo "فایل $file_path به‌روزرسانی شد."
        FILES_CHANGED=1
    else
        echo "فایل $file_path نیازی به به‌روزرسانی ندارد."
    fi
}

# بررسی مجوز فایل‌ها
check_permissions "$ROUTE_FILE"
check_permissions "$SING_FILE"

# بررسی و به‌روزرسانی فایل‌ها
FILES_CHANGED=0
update_file_if_needed "$ROUTE_FILE" "$NEW_ROUTE_JSON"
update_file_if_needed "$SING_FILE" "$NEW_SING_ORIGIN_JSON"

# اگر فایل‌ها تغییر کرده باشند، سرویس v2bx را restart کنید
if [ $FILES_CHANGED -eq 1 ]; then
    echo "فایل‌ها تغییر کردند. v2bx در حال راه‌اندازی مجدد است..."
    v2bx restart
else
    echo "هیچ فایلی تغییر نکرده است. نیازی به راه‌اندازی مجدد نیست."
fi

echo "پیکربندی فایل‌ها بررسی و در صورت نیاز به‌روزرسانی شدند."
