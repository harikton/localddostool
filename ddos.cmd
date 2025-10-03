chcp 65001 >nul && cls

@echo off && title DdosChivarly Version 1.0
setlocal enabledelayedexpansion
echo DdosChivarly Ver 1.0
echo.
ping -n 2 localhost >nul

echo Определение вашего IP адреса...
echo.

rem Получаем шлюз по умолчанию
set gateway=
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /C:"Основной шлюз" /C:"Default Gateway"') do (
    if not defined gateway (
        set "gateway=%%i"
        set "gateway=!gateway: =!"
    )
)

if not defined gateway (
    echo Не удалось определить шлюз по умолчанию   
) else (
    echo Шлюз по умолчанию: !gateway!
)


echo.
ping -n 1 !gateway! >nul 2>&1

:show_ipconfig
echo Определение через ipconfig:
set ipNumber=0
for /f "tokens=1,2 delims=:" %%i in ('ipconfig ^| findstr /C:"IPv4"') do (
    set /a ipNumber+=1
    set "ip=%%j"
    set "ip=!ip: =!"
    set "GlobalIP!ipNumber!=!ip!"
    echo IP: !ip!
)
echo.
echo IP-адреса занесены в список избегания. (На данные IP-адреса запросы отправлены не будут.)
echo Генерирую список IP-адресов для отправки запросов. 
ping -n 2 localhost >nul
echo.

set /a countRequest=0
set text=?

echo Список сгенерирован. Введите кол-во запросов которое хотите отправить: 
set /p main="DdosChivarly> "
set /a countRequest=%main% 2>nul

if %countRequest% leq 0 (
    echo Введите верное число
    pause
    exit
)

echo Введите текст:
set /p mainT="DdosChivarly> "

if "%mainT%"=="" (
    set "text=?"
) else (
    set "text=%mainT%"
)

echo.
echo Будет отправлено запросов: %countRequest%
echo С текстом: %text%
echo.
pause


echo [Запуск отправки запросов...]
echo.
ping -n 2 localhost >nul
set farip=0
set /a total_sent=0

for /l %%i in (1,1,%countRequest%) do (
    echo.
    echo [Пакет номер: %%i/%countRequest%]
    
    set farip=0
    for /l %%j in (1,1,256) do (
        set /a farip+=1
        set requestip=192.168.0.!farip!
        
        set skip_ip=0
        rem Проверяем, не совпадает ли IP с нашими адресами
        for /l %%k in (1,1,!ipNumber!) do (
            if "!requestip!"=="!GlobalIP%%k!" (
                set skip_ip=1
            )
        )
        
        if !skip_ip!==0 (
            echo [ОТПРАВКА] Запрос к !requestip! с текстом: %text%
            set /a total_sent+=1
            rem Здесь можно добавить реальную отправку, например:
            rem ping -n 1 !requestip! >nul 2>&1
            rem curl http://!requestip!/%text% >nul 2>&1
        ) else (
            echo [ПРОПУСК] !requestip! - ваш IP адрес
        )
    )
    echo [Пакет %%i завершен]
    ping -n 1 localhost >nul
)

echo.
echo ========================================
echo [СТАТИСТИКА]
echo Всего пакетов отправлено: %countRequest%
echo Всего IP обработано: %total_sent%
echo Ваши IP адреса в избегании: !ipNumber!
echo ========================================
echo.
echo Операция завершена.
pause
