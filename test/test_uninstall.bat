@echo off
setlocal

set PATH=%~dp0..\bin;%~dp0..\shims;%PATH%

echo :uninstall: test
call rbenv versions
call rbenv uninstall 2.1.8
call rbenv uninstall 2.1.7-x64
call rbenv uninstall 1.9.3-p551
