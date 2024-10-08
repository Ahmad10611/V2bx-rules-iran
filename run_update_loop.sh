#!/bin/bash

while true; do
    # تبدیل اسکریپت به فرمت یونیکس
    /usr/bin/dos2unix /root/V2bx-rules-iran/update_v2bx_configs.sh

    # اجرای اسکریپت پیکربندی
    /bin/bash /root/V2bx-rules-iran/update_v2bx_configs.sh

    # لاگ کردن اجرای موفقیت‌آمیز
    echo "$(date) - Script executed successfully" >> /root/cronjob_output.log

    # خوابیدن برای 10 ثانیه
    sleep 10
done
