set folder=%1
set ecf=%2
set target=%3

cd ..\%folder%
ec -config %ecf%.ecf -target %target% -clean
cd eifgens\%ecf%\W_code
finish_freezing
cd ..\..\..

ec -config %ecf%.ecf -target test -clean
cd eifgens\test\W_code
finish_freezing
cd ..\..\..
