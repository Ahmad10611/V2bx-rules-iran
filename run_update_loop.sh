[Unit]
Description=Run Update Loop Script

[Service]
ExecStart=/bin/bash /root/V2bx-rules-iran/run_update_loop.sh
Restart=always

[Install]
WantedBy=multi-user.target
