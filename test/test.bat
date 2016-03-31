@echo off
setlocal

set PATH=%~dp0..\bin;%~dp0..\shims;%PATH%

echo :install: test
call rbenv install -l
call rbenv install 2.1.8
call rbenv install 2.1.7-x64
call rbenv install 1.9.3-p551


mkdir test
cd test
echo :global: test
call rbenv global 2.1.8
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions

echo :local: test
call rbenv local 2.1.7-x64
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions
cd ..
call ruby -v
call rbenv version
call rbenv versions
cd test
call ruby -v
call rbenv version
call rbenv versions

echo :shell: test
call rbenv shell 1.9.3-p551
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions
cd ..
call ruby -v
call rbenv version
call rbenv versions
cd test
call ruby -v
call rbenv version
call rbenv versions

echo :shell --unset: test
call rbenv shell --unset
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions

echo :local --unset: test
call rbenv local --unset
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions

cd ..
rmdir /s /q test

echo :rehash: test
call rbenv shell 2.1.8
call rbenv rehash
call gem install bundler
call where bundle
call rbenv rehash
call where bundle


echo :DevKit i386: test
call xcopy "%~dp0\gem_rake_bundler" "%~dp0test\" /E /H /R /K /Y /I /F
cd test
call rbenv shell 2.1.8
call rbenv rehash
call gem install bundler
call rbenv rehash
call bundle install --path vendor/bundle
call bundle platform
call bundle exec rake
cd ..
rmdir /s /q test

echo :DevKit x64: test
call xcopy "%~dp0\gem_rake_bundler" "%~dp0test\" /E /H /R /K /Y /I /F
cd test
call rbenv shell 2.1.7-x64
call rbenv rehash
call gem install bundler
call rbenv rehash
call bundle install --path vendor/bundle
call bundle platform
call bundle exec rake
cd ..
rmdir /s /q test

echo :DevKit tdm: test
call xcopy "%~dp0\gem_rake_bundler" "%~dp0test\" /E /H /R /K /Y /I /F
cd test
call rbenv shell 1.9.3-p551
call rbenv rehash
call gem install rubygems-update
call rbenv rehash
call update_rubygems
call rbenv rehash
call gem install bundler
call rbenv rehash
call bundle install --path vendor/bundle
call bundle platform
call bundle exec rake
cd ..
rmdir /s /q test

