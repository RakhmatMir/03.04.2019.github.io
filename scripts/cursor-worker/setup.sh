#!/usr/bin/env bash
# Настройка Cursor My Machines worker на вашем сервере.
# После установки сервер появится в мобильном приложении Cursor.
set -euo pipefail

WORKER_NAME="${WORKER_NAME:-romanoff-server}"
REPO_URL="${REPO_URL:-https://github.com/RakhmatMir/03.04.2019.github.io.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/cursor-projects/03.04.2019.github.io}"
AGENT_BIN="${AGENT_BIN:-$HOME/.local/bin/agent}"

echo "=== Cursor My Machines: установка worker ==="
echo "Имя машины:  $WORKER_NAME"
echo "Папка:       $INSTALL_DIR"
echo ""

if ! command -v git >/dev/null 2>&1; then
  echo "Ошибка: git не установлен. Установите: sudo apt install -y git"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Ошибка: curl не установлен. Установите: sudo apt install -y curl"
  exit 1
fi

if [[ ! -x "$AGENT_BIN" ]]; then
  echo ">>> Устанавливаю Cursor CLI..."
  curl https://cursor.com/install -fsS | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ ! -x "$AGENT_BIN" ]]; then
  echo "Ошибка: agent не найден в $AGENT_BIN"
  exit 1
fi

echo ">>> Версия CLI: $($AGENT_BIN --version)"
echo ""

if ! "$AGENT_BIN" whoami >/dev/null 2>&1; then
  echo ">>> Нужен вход в Cursor. Откроется браузер или ссылка для авторизации."
  echo "    Выполните вход тем же аккаунтом, что и в мобильном приложении."
  "$AGENT_BIN" login
fi

echo ""
echo ">>> Аккаунт: $("$AGENT_BIN" whoami 2>/dev/null || echo 'не определён')"
echo ""

mkdir -p "$(dirname "$INSTALL_DIR")"
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  echo ">>> Клонирую репозиторий..."
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  echo ">>> Репозиторий уже есть: $INSTALL_DIR"
fi

echo ""
echo ">>> Проверка подключения (preflight)..."
"$AGENT_BIN" worker start \
  --name "$WORKER_NAME" \
  --worker-dir "$INSTALL_DIR" \
  --debug &
PREFLIGHT_PID=$!
sleep 8
kill "$PREFLIGHT_PID" 2>/dev/null || true
wait "$PREFLIGHT_PID" 2>/dev/null || true

SERVICE_FILE="/etc/systemd/system/cursor-worker.service"
UNIT_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/cursor-worker.service"

echo ""
read -r -p "Установить автозапуск через systemd? [y/N] " USE_SYSTEMD
USE_SYSTEMD="${USE_SYSTEMD:-N}"

if [[ "$USE_SYSTEMD" =~ ^[Yy]$ ]]; then
  if [[ $EUID -ne 0 ]]; then
  sudo env \
    WORKER_USER="$USER" \
    WORKER_NAME="$WORKER_NAME" \
    INSTALL_DIR="$INSTALL_DIR" \
    AGENT_BIN="$AGENT_BIN" \
    bash -c '
      sed \
        -e "s|@WORKER_USER@|$WORKER_USER|g" \
        -e "s|@WORKER_NAME@|$WORKER_NAME|g" \
        -e "s|@INSTALL_DIR@|$INSTALL_DIR|g" \
        -e "s|@AGENT_BIN@|$AGENT_BIN|g" \
        "'"$UNIT_SOURCE"'" > /etc/systemd/system/cursor-worker.service
      systemctl daemon-reload
      systemctl enable cursor-worker
      systemctl restart cursor-worker
    '
  else
    sed \
      -e "s|@WORKER_USER@|$USER|g" \
      -e "s|@WORKER_NAME@|$WORKER_NAME|g" \
      -e "s|@INSTALL_DIR@|$INSTALL_DIR|g" \
      -e "s|@AGENT_BIN@|$AGENT_BIN|g" \
      "$UNIT_SOURCE" > "$SERVICE_FILE"
    systemctl daemon-reload
    systemctl enable cursor-worker
    systemctl restart cursor-worker
  fi

  echo ""
  echo ">>> Статус сервиса:"
  systemctl status cursor-worker --no-pager || true
else
  echo ""
  echo ">>> Запуск worker вручную (окно должно оставаться открытым):"
  echo "    $AGENT_BIN worker start --name \"$WORKER_NAME\" --worker-dir \"$INSTALL_DIR\""
  echo ""
  echo "    Или в фоне:"
  echo "    nohup $AGENT_BIN worker start --name \"$WORKER_NAME\" --worker-dir \"$INSTALL_DIR\" > \"$HOME/cursor-worker.log" 2>&1 &"
fi

cat <<EOF

=== Готово ===

1. Откройте Cursor на телефоне (тот же аккаунт).
2. Создайте нового агента.
3. В списке окружений выберите: $WORKER_NAME
4. Напишите задачу, например: "Покажи файлы в проекте и открой index.html"

Полезные команды:
  sudo systemctl status cursor-worker
  sudo journalctl -u cursor-worker -f
  $AGENT_BIN worker start --debug --name "$WORKER_NAME" --worker-dir "$INSTALL_DIR"

Документация: https://cursor.com/docs/cloud-agent/my-machines
EOF
