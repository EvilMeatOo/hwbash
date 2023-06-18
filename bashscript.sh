#!/bin/bash

# Путь к файлу, который будет использоваться для блокировки
LOCKFILE=~/script.lock
# Путь к файлу, в котором будет храниться время последнего запуска скрипта
LAST_RUN_FILE=~/last_run.txt

# Проверка наличия файла блокировки
if [ -e "$LOCKFILE" ]; then
  echo "Скрипт уже выполняется. Выход."
  exit 1
else
  # Создание файла блокировки
  touch "$LOCKFILE"
fi

# Функция для удаления файла блокировки и временных файлов при завершении скрипта
cleanup() {
  rm -f "$LOCKFILE" "$IP_FILE" "$URL_FILE" "$ERROR_FILE" "$HTTP_CODES_FILE"
  exit
}

# Зарегистрировать функцию cleanup для обработки сигналов завершения скрипта
trap cleanup EXIT

# Проверка наличия файла с временем последнего запуска скрипта
if [ -e "$LAST_RUN_FILE" ]; then
  # Чтение времени последнего запуска из файла
  last_run=$(cat "$LAST_RUN_FILE")
else
  last_run="Нет данных о предыдущем запуске"
fi

# Сохранение текущего времени в файл последнего запуска
echo "$(date "+%d-%m-%Y %H:%M:%S")" > "$LAST_RUN_FILE"

# Переменные для хранения информации
IP_FILE=~/ip.txt
URL_FILE=~/url.txt
ERROR_FILE=~/error.txt
HTTP_CODES_FILE=~/http_codes.txt

# Команда для получения списка IP адресов с наибольшим количеством запросов
ip_cmd="awk '{print \$1}' ~/access.log | sort | uniq -c | sort -rn | head -n 10"
eval "$ip_cmd > $IP_FILE"

# Команда для получения списка URL с наибольшим количеством запросов
url_cmd="awk '{print \$7}' ~/access.log | sort | uniq -c | sort -rn | head -n 10"
eval "$url_cmd > $URL_FILE"

# Команда для получения ошибок
error_cmd="grep 'error' ~/error.log > $ERROR_FILE"
eval "$error_cmd"

# Команда для получения списка всех кодов HTTP ответа
http_codes_cmd="awk '{print \$9}' ~/access.log | sort | uniq -c"
eval "$http_codes_cmd > $HTTP_CODES_FILE"

# Отправка письма с информацией
mail_subject="Отчет за последний час"
mail_recipient="example@example.com"

mail_body="Время последнего запуска скрипта: $last_run

Временной диапазон выполнения скрипта:
Начало: $(date "+%d-%m-%Y %H:%M:%S")
Конец: $(date "+%d-%m-%Y %H:%M:%S")

Список IP адресов (с наибольшим количеством запросов):
$(cat $IP_FILE)

Список запрашиваемых URL (с наибольшим количеством запросов):
$(cat $URL_FILE)

Ошибки веб-сервера/приложения:
$(cat $ERROR_FILE)

Список всех кодов HTTP ответа:
$(cat $HTTP_CODES_FILE)"

echo "$mail_body" | mail -s "$mail_subject" "$mail_recipient"

# Завершение скрипта и удаление файла блокировки
cleanup
