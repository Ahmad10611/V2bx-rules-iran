#!/bin/bash

# چک کردن دسترسی روت
if [ "$EUID" -ne 0 ]; then
  echo "لطفاً به‌عنوان کاربر روت اجرا کنید"
  exit
fi

# بروزرسانی بسته‌ها
echo "در حال بروزرسانی بسته‌های سیستم..."
apt-get update -y

# نصب git در صورت نیاز
if ! command -v git &> /dev/null; then
  echo "در حال نصب git..."
  apt-get install git -y
fi

# کلون کردن مخزن
echo "در حال کلون کردن مخزن..."
git clone https://github.com/Ahmad10611/V2bx-rules-iran.git /root/V2bx-rules-iran

# چک کردن اینکه آیا مخزن به درستی کلون شده است
if [ ! -d "/root/V2bx-rules-iran" ]; then
  echo "کلون مخزن با مشکل مواجه شد. نصب متوقف شد."
  exit 1
fi

# تنظیم مجوز فایل‌های JSON
echo "تنظیم مجوزهای فایل‌ها..."
chmod 755 /root/V2bx-rules-iran/*.json

# افزودن اسکریپت به کرونت برای اجرا هر دقیقه
echo "افزودن به کرونت..."
(crontab -l 2>/dev/null; echo "* * * * * bash /root/V2bx-rules-iran/update_v2bx_configs.sh >> /root/v2bx_update.log 2>&1") | crontab -

# ریلود کردن کرون
echo "ریلود کردن سرویس کرون..."
service cron reload

# پیام نهایی
echo "نصب و پیکربندی با موفقیت انجام شد. اسکریپت هر دقیقه اجرا خواهد شد."
