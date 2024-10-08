#!/bin/bash

# بروزرسانی پکیج‌ها و نصب dos2unix
sudo apt-get update
sudo apt-get install -y dos2unix git

# دانلود اسکریپت‌ها از مخزن گیت‌هاب
git clone https://github.com/USERNAME/V2bx-rules-iran.git /root/V2bx-rules-iran

# تبدیل اسکریپت به فرمت یونیکس
dos2unix /root/V2bx-rules-iran/run_update_loop.sh
dos2unix /root/V2bx-rules-iran/update_v2bx_configs.sh

# ایجاد فایل سرویس systemd
cat <<EOT >> /etc/systemd/system/run_update_loop.service
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

# فعال‌سازی و راه‌اندازی سرویس
sudo systemctl enable run_update_loop.service
sudo systemctl start run_update_loop.service

echo "Installation and setup completed successfully!"
