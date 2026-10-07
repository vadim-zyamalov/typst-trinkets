@echo off

cls

set FILE=""
set FROM="."
set TO="."
set INTER="."

:GETOPTS
if /I "%1" == "-f" set "FILE=%2" & shift & shift
if /I "%1" == "-src" set "FROM=%2" & shift & shift
if /I "%1" == "-tgt" set "TO=%2" & shift & shift
if /I "%1" == "-aux" set "INTER=%2" & shift & shift

set FILE=%FILE:"=%
set FROM=%FROM:"=%
set TO=%TO:"=%
set INTER=%INTER:"=%

if not "%1"=="" goto GETOPTS

if not "%FILE%"=="" (
	call :PROCESS "%FILE%"
) else (
	for %%f in ("%FROM%"\*.ipynb) do (
		call :PROCESS "%%~nf"
	)
)

goto :EOF

:PROCESS
echo Processing "%FROM%\%~1.ipynb" to "%TO%\%~1.pdf"
echo Making dirs and links

if not exist "%INTER%" mkdir "%INTER%"
if not exist "%TO%" mkdir "%TO%"
if not "%INTER%"=="%FROM%" if not exist "%INTER%\.pics" mklink /J "%INTER%\.pics" "%FROM%\.pics"

echo Calling NBconvert
rem uv run jupyter nbconvert --execute --allow-errors --to notebook --output-dir="%INTER%" "%FROM%\%~1.ipynb"

echo Preparing "%INTER%\%~1.typ"
copy ju2pdft.typ "%INTER%\%~1.typ"
py ju2pdft.py "%~1" "%INTER%"

echo Calling typst
typst c "%INTER%\%~1.typ"

copy "%INTER%\%~1.pdf" "%TO%\%~1.pdf"

goto :EOF
