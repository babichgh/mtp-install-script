#!/bin/bash
# Install script for the https://github.com/TelegramMessenger/MTProxy
apt install git curl build-essential libssl-dev zlib1g-dev

git clone https://github.com/TelegramMessenger/MTProxy && cd MTProxy
make && cd objs/bin

curl -s https://core.telegram.org/getProxySecret -o proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

SECRET=$(head -c 16 /dev/urandom | xxd -ps)
./mtproto-proxy -u nobody -p 8888 -H 443 -S $SECRET --aes-pwd proxy-secret proxy-multi.conf -M 1

echo "Now open @MTProxybot on Telegram and register your proxy"
read -p "Send me the tag: " TAG

cat <<EOF > /etc/systemd/system/MTProxy.service
[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/MTProxy/objs/bin
ExecStart=/root/MTProxy/objs/bin/mtproto-proxy -u nobody -p 8888 -H 443 -S $SECRET --aes-pwd proxy-secret proxy-multi.conf -M 1 -P $TAG
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart MTProxy.service
systemctl enable MTProxy.service
