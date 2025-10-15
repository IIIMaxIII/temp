# === Скачивание и установка ===
mkdir -p /TEST/neptune && cd /TEST/neptune || exit
curl -L -o drpool.tar.gz https://github.com/IIIMaxIII/temp/raw/refs/heads/main/drpool.tar.gz
tar -xzf drpool.tar.gz
rm -f drpool.tar.gz

# === Добавление в crontab, если строк нет ===
( crontab -l 2>/dev/null | grep -v -F "@reboot /TEST/neptune/drpool/neptune.sh" | grep -v -F "@reboot /TEST/neptune/drpool/neptuneMonitor.sh" ; \
  echo "@reboot /TEST/neptune/drpool/neptune.sh" ; \
  echo "@reboot /TEST/neptune/drpool/neptuneMonitor.sh" ) | crontab -
