chcp 65001

set LNAME=%~1
if "%LNAME%"=="" set LNAME=local
set LNAME=%LNAME: =_%

if not exist %localappdata%\typst\packages\%LNAME% (
	sudo mklink /D "%localappdata%\typst\packages\%LNAME%" "%cd%\local"
)
