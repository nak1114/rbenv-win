@echo off
call bundle show > NUL
if ERRORLEVEL 1 (
rbenv exec %~n0 %*
) else (
bundle exec %~n0 %*
)
