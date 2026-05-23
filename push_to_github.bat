@echo off
cd /d "%~dp0"

git status
git add .
set /p MSG=Commit message: 
git commit -m "%MSG%"
git push

pause
