@echo off
set PATH=C:\Ruby34-x64\bin;C:\Ruby34-x64\msys64\ucrt64\bin;C:\Ruby34-x64\msys64\usr\bin;%PATH%
echo Iniciando AppMyLife (Ruby on Rails 8 + Hotwire) en http://localhost:3000 ...
ruby bin/rails server -p 3000
