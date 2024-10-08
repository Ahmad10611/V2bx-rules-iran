#!/bin/bash

# بروزرسانی پکیج‌ها و نصب dos2unix
sudo apt-get update
sudo apt-get install -y dos2unix git

# اگر دایرکتوری از قبل وجود دارد، به مسیر بالاتر بروید و سپس دایرکتوری را حذف کنید
if [ -d "/root/V2bx-rules-iran" ]; then
    echo "Removing existing /root/V2bx-rules-iran directory..."
    cd /root  # تغییر مسیر به /root
    sudo rm -rf /root/V2bx-rules-iran
fi

# کلون کردن پروژه از گیت‌هاب
git clone https://github.com/Ahmad10611/V2bx-rules-iran.git /root/V2bx-rules-iran

# تبدیل اسکریپت‌ها به فرمت یونیکس
dos2unix /root/V2bx-rules-iran/run_update_loop.sh
dos2unix /root/V2bx-rules-iran/update_v2bx_configs.sh

# حذف فایل سرویس قبلی (در صورت وجود)
if [ -f "/etc/systemd/system/run_update_loop.service" ]; then
    echo "Removing old run_update_loop.service..."
    sudo rm /etc/systemd/system/run_update_loop.service
fi

# ایجاد فایل سرویس systemd با محتوای جدید
cat <<EOT > /etc/systemd/system/run_update_loop.service
[Unit]
Description=Run Update Loop Script

[Service]
ExecStart=/bin/bash /root/V2bx-rules-iran/run_update_loop.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# تغییر مجوز اسکریپت‌ها به قابل اجرا
chmod +x /root/V2bx-rules-iran/run_update_loop.sh
chmod +x /root/V2bx-rules-iran/update_v2bx_configs.sh

# بارگذاری مجدد تنظیمات سرویس‌های systemd
sudo systemctl daemon-reload

# فعال‌سازی و راه‌اندازی سرویس
sudo systemctl enable run_update_loop.service
sudo systemctl start run_update_loop.service

echo "Installation and setup completed successfully!"
