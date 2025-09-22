#!/usr/bin/env bash
set -euo pipefail

apt update -qq
apt install -y build-essential python3-flask mariadb-server apache2 docker.io gcc make git cron ssh

# SUID binary
gcc /home/vagrant/obscura/oldbackup.c -o /usr/bin/oldbackup
chmod u+s /usr/bin/oldbackup

# Flask apps
mkdir -p /var/www/obscura /opt/internal-api
cp /home/vagrant/obscura/app.py /var/www/obscura/
cp /home/vagrant/obscura/api.py /opt/internal-api/

# Apache banner spoof
cp /home/vagrant/obscura/config/security.conf /etc/apache2/conf-enabled/security.conf

# Fake .git
mkdir -p /var/www/html/admin/.git
echo "[remote \"origin\"]\n\turl = https://github.com/fakecorp/obscura-admin.git" > /var/www/html/admin/.git/config

# Cron rabbit hole
cp /home/vagrant/obscura/rotate.sh /usr/local/bin/rotate.sh
chmod +x /usr/local/bin/rotate.sh
echo "* * * * * root /usr/local/bin/rotate.sh" > /etc/cron.d/fake-rotate

# MariaDB setup
service mariadb start
mysql -e "CREATE USER 'webuser'@'localhost' IDENTIFIED BY 'webpass';"
mysql -e "GRANT FILE ON *.* TO 'webuser'@'localhost';"

# Real escalation
cp /home/vagrant/obscura/.cron.sh /home/webuser/.cron.sh
chown webuser:webuser /home/webuser/.cron.sh
chmod +x /home/webuser/.cron.sh
echo "* * * * * webuser bash /home/webuser/.cron.sh" > /etc/cron.d/webcron

# Decoy and real creds
cp /home/vagrant/obscura/.env /var/www/html/.env
cp /home/vagrant/obscura/.env.b64 /opt/internal-api/.env.b64

# SSH banner
cp /home/vagrant/obscura/config/ssh-banner.txt /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# Enable services
systemctl daemon-reexec
systemctl enable apache2 mariadb docker ssh cron
systemctl restart apache2 mariadb ssh cron

# Docker group
usermod -aG docker webuser
