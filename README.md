ДЗ: Cкрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.

Необходимая информация в письме:

1. Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
2. Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
3. Ошибки веб-сервера/приложения c момента последнего запуска;
4. Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.

Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения. В письме должен быть прописан обрабатываемый временной диапазон.

Чтобы добавить скрипт в CRON необходимо набрать crontab -e. В открывшемся редакторе в конец добавить строку
```
0 * * * * /path/to/your/bashscript.sh
```
Скрипт будет выполнятся каждый час в нулевую минуту.
