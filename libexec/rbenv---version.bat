@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv --version
echo.
echo Displays the version number of this rbenv release, including the
echo current revision from git, if available.
echo.
echo The format of the git revision is:
echo   ^<version^>-^<num_commits^>-^<git_sha^>
echo where `num_commits` is the number of commits since `version` was
echo tagged.
echo.
EXIT /B
)

echo rbenv 0.0.5-06
