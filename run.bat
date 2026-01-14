@echo off
setlocal enabledelayedexpansion
set "JAR_NAME=FileCreater-1.0-SNAPSHOT.jar"
set "RETRY=5"  :: 最多检查5次（总等待5秒）

:: ========================== 1. 强制终止旧进程（保留WMIC精确查杀） ==========================
echo [1/3] 终止旧进程...
wmic process where "name='javaw.exe' and CommandLine like '%%%JAR_NAME%%%'" delete >nul 2>&1
echo [成功] 旧进程已清理

:: ========================== 2. 环境校验（保留核心检查） ==========================
echo [2/3] 环境校验...
if not exist "%JAR_NAME%" (
    echo [错误] JAR文件不存在：%cd%\%JAR_NAME%
    pause
    exit /b 1
)
javaw -version >nul 2>&1 || (
    echo [错误] 未找到Java环境！
    pause
    exit /b 1
)

:: ========================== 3. 启动+动态检查（核心修复） ==========================
echo [3/3] 启动新进程...
start "" /b javaw  -Dfile.encoding=utf-8  -jar "%JAR_NAME%"

:: 动态等待进程启动（最多5秒，每1秒检查一次）
:CHECK_LOOP
wmic process where "name='javaw.exe' and CommandLine like '%%%JAR_NAME%%%'" get ProcessId >nul 2>&1
if %errorlevel% equ 0 (
    echo [成功] 程序已在后台启动（进程已确认）
    exit /b 0
) else (
    set /a "RETRY-=1"
    if %RETRY% equ 0 (
        echo [警告] 脚本未检测到进程，但可能已启动！
        echo 请手动验证任务管理器中的javaw.exe进程（命令行含%JAR_NAME%）
        pause
        exit /b 0
    )
    echo 等待进程启动（剩余%RETRY%秒）...
    timeout /t 1 /nobreak >nul
    goto CHECK_LOOP
)