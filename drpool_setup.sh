#!/bin/bash
# Скрипт установки и удаления drpool с GitHub и настройкой cron

INSTALL_DIR="/TEST/neptune/drpool"
GITHUB_URL="https://github.com/IIIMaxIII/temp/raw/refs/heads/main/drpool.tar.gz"
SCRIPT_FILE="$INSTALL_DIR/neptune.sh"
MONITOR_FILE="$INSTALL_DIR/neptuneMonitor.sh"
CRON_FILE="/hive/etc/crontab.root"

# --------------------------
# Функция установки
# --------------------------
install_drpool() {
    echo "=== Установка drpool ==="
    
    # Скачивание и распаковка
    mkdir -p "$INSTALL_DIR"
    curl -L -o "$INSTALL_DIR/drpool.tar.gz" "$GITHUB_URL"
    tar -xzf "$INSTALL_DIR/drpool.tar.gz" -C "$INSTALL_DIR"
    rm -f "$INSTALL_DIR/drpool.tar.gz"
    echo "Файлы распакованы в $INSTALL_DIR"

    # Добавление в обычный crontab, если нет
    ( crontab -l 2>/dev/null | grep -v -F "@reboot $SCRIPT_FILE" | grep -v -F "@reboot $MONITOR_FILE" ; \
      echo "@reboot $SCRIPT_FILE" ; \
      echo "@reboot $MONITOR_FILE" ) | crontab -

    # Добавление в /hive/etc/crontab.root, если нет
    grep -qxF "@reboot $SCRIPT_FILE" "$CRON_FILE" || printf "\n@reboot %s\n" "$SCRIPT_FILE" >> "$CRON_FILE"
    grep -qxF "@reboot $MONITOR_FILE" "$CRON_FILE" || printf "\n@reboot %s\n" "$MONITOR_FILE" >> "$CRON_FILE"

    echo "Строки добавлены в cron и $CRON_FILE"
}

# --------------------------
# Функция удаления
# --------------------------
remove_drpool() {
    echo "=== Удаление drpool из cron ==="

    # Удаление из обычного crontab
    crontab -l 2>/dev/null | grep -v -F "@reboot $SCRIPT_FILE" | grep -v -F "@reboot $MONITOR_FILE" | crontab -

    # Удаление из /hive/etc/crontab.root
    grep -vxF "@reboot $SCRIPT_FILE" "$CRON_FILE" | grep -vxF "@reboot $MONITOR_FILE" > "${CRON_FILE}.tmp" && mv "${CRON_FILE}.tmp" "$CRON_FILE"

    echo "Строки удалены из cron и $CRON_FILE"
}

# --------------------------
# Основной блок
# --------------------------
case "$1" in
    install)
        install_drpool
        ;;
    remove)
        remove_drpool
        ;;
    *)
        echo "Использование: $0 {install|remove}"
        exit 1
        ;;
esac
