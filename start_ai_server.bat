@echo off
echo Starting Molvi AI Server...
pushd "%~dp0lib\ChatBot\Server"
node index.js
popd
pause
