@echo off
REM ============================================================
REM stardust - 推送到 GitHub 批处理
REM 仓库: https://github.com/BenbenFu/stardust
REM 用法: 双击运行，按提示操作
REM ============================================================

set REPO=https://github.com/BenbenFu/stardust.git
set BRANCH=main

echo.
echo ==========================================
echo   stardust - Git 推送助手
echo ==========================================
echo.

REM --- 第1步：检查 git ---
where git >nul 2>&1
if %errorlevel% neq 0 (
  echo [X] 未找到 git，请先安装 Git for Windows
  echo     下载地址：https://git-scm.com/download/win
  pause
  exit /b 1
)
echo [OK] Git 已安装

REM --- 第2步：初始化（如果尚未初始化）---
if not exist ".git\" (
  echo [..] 初始化 Git 仓库...
  git init
  git branch -M %BRANCH%
  echo [OK] Git 仓库初始化完成
) else (
  echo [OK] 已是 Git 仓库
  git branch -M %BRANCH%
)

REM --- 第3步：设置远程仓库 ---
git remote get-url origin >nul 2>&1
if %errorlevel%==0 (
  echo [OK] 远程仓库已设置：%REPO%
) else (
  git remote add origin %REPO%
  echo [OK] 已添加远程仓库
)

REM --- 第4步：拉取远程内容（合并 index.html 等已有文件）---
echo.
echo [..] 拉取远程内容（如有）...
git pull origin %BRANCH% --allow-unrelated-histories --no-edit 2>nul
if %errorlevel% neq 0 (
  echo [!] 拉取失败或远程为空（可忽略，继续推送）
)

REM --- 第5步：暂存文件 ---
echo.
echo [..] 暂存文件...
git add .

echo.
echo [待提交文件]
git status --short

echo.
REM --- 第6步：提交 ---
set /p COMMIT_MSG="输入提交说明（回车用默认）："
if "%COMMIT_MSG%"=="" set COMMIT_MSG=feat: initial commit of stardust firmware

git commit -m "%COMMIT_MSG%"
if %errorlevel% neq 0 (
  echo [!] 提交失败，可能没有变更，尝试直接推送...
)

REM --- 第7步：推送 ---
echo.
echo ==========================================
echo   推送到 GitHub
echo ==========================================
echo.
echo 选择身份验证方式：
echo   1^) 输入 GitHub Token（推荐，一次填入即可）
echo   2^) 手动输入（Git Credential Manager 会弹窗/提示）
echo.
set /p AUTH_CHOICE="选择 [1/2]，默认1："
if "%AUTH_CHOICE%"=="2" goto :manual_push

REM --- Token 方式推送 ---
set /p TOKEN="粘贴你的 GitHub Personal Access Token（ghp_开头）："
if "%TOKEN%"=="" (
  echo [!] Token 为空，改用手动方式
  goto :manual_push
)

set REPO_AUTH=https://BenbenFu:%TOKEN%@github.com/BenbenFu/stardust.git
echo [..] 使用 Token 推送（临时写入 remote URL）...
git remote set-url origin %REPO_AUTH%
git push -u origin %BRANCH%
set PUSH_RESULT=%errorlevel%
git remote set-url origin https://github.com/BenbenFu/stardust.git
if %PUSH_RESULT%==0 goto :push_done
echo [X] Token 推送失败，错误码 %PUSH_RESULT%
pause
exit /b %PUSH_RESULT%

:manual_push
echo.
echo 即将弹窗/提示输入凭据：
echo   用户名：BenbenFu
echo   密码：粘贴你的 Personal Access Token（不是 GitHub 登录密码）
echo.
echo [如何获取 Token]
echo   1. 访问 https://github.com/settings/tokens
echo   2. 点击 "Generate new token (classic)"
echo   3. 勾选 "repo" 权限
echo   4. 生成后复制，粘贴到密码框
echo.
pause

git push -u origin %BRANCH%

:push_done
if %errorlevel%==0 (
  echo.
  echo ==========================================
  echo   [OK] 推送成功！
  echo   仓库地址：https://github.com/BenbenFu/stardust
  echo ==========================================
) else (
  echo.
  echo [X] 推送失败，请检查：
  echo   1. 仓库是否存在：https://github.com/BenbenFu/stardust
  echo   2. Token 是否有 repo 权限
  echo   3. 如果远程有内容，先执行：git pull origin main --allow-unrelated-histories
  echo.
  echo 也可手动执行：
  echo   git push -u origin main
)
echo.
pause
