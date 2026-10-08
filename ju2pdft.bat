@echo off

cls

set PYFILE=ju2pdf.py
set TYFILE=ju2pdf.typ

set FILE=""
set FROM="."
set TO="."
set INTER="."
set SKIP=0

:GETOPTS
if /I "%1" == "-skip" set SKIP=1 & shift
if /I "%1" == "-f" set "FILE=%2" & shift & shift
if /I "%1" == "-src" set "FROM=%2" & shift & shift
if /I "%1" == "-tgt" set "TO=%2" & shift & shift
if /I "%1" == "-aux" set "INTER=%2" & shift & shift

set FILE=%FILE:"=%
set FROM=%FROM:"=%
set TO=%TO:"=%
set INTER=%INTER:"=%

if not "%1"=="" goto GETOPTS

call :MAKEPY
call :MAKETY

if not "%FILE%"=="" (
	call :PROCESS "%FILE%"
) else (
	for %%f in ("%FROM%"\*.ipynb) do (
		call :PROCESS "%%~nf"
	)
)

del "%TEMP%\%PYFILE%" "%TEMP%\%TYFILE%"

goto :EOF

:PROCESS
echo Processing "%FROM%\%~1.ipynb" to "%TO%\%~1.pdf"
echo Making dirs and links

if not exist "%INTER%" mkdir "%INTER%"
if not exist "%TO%" mkdir "%TO%"
if not "%INTER%"=="%FROM%" if not exist "%INTER%\.pics" mklink /J "%INTER%\.pics" "%FROM%\.pics"

if %SKIP%==0 (
	echo Calling NBconvert
	uv run jupyter nbconvert --execute --allow-errors --to notebook --output-dir="%INTER%" "%FROM%\%~1.ipynb"
)

echo Preparing "%INTER%\%~1.typ"
copy "%TEMP%\%TYFILE%" "%INTER%\%~1.typ"
py "%TEMP%\%PYFILE%" "%~1" "%INTER%"

echo Calling typst
typst c "%INTER%\%~1.typ"

copy "%INTER%\%~1.pdf" "%TO%\%~1.pdf"

goto :EOF


:MAKEPY
>%TEMP%\%PYFILE%	echo import sys
>>%TEMP%\%PYFILE%	echo import tempfile
>>%TEMP%\%PYFILE%	echo fname = sys.argv[1]
>>%TEMP%\%PYFILE%	echo outdir = sys.argv[2]
>>%TEMP%\%PYFILE%	echo with open(f"{tempfile.gettempdir()}\\ju2pdf.typ", "r", encoding="utf8") as f:
>>%TEMP%\%PYFILE%	echo     lines = f.readlines()
>>%TEMP%\%PYFILE%	echo with open(f"{outdir}/{fname}.typ", "w", encoding="utf8") as f:
>>%TEMP%\%PYFILE%	echo     f.writelines(line.replace("<DUMMY>", fname) for line in lines)
goto :EOF


:MAKETY
>%TEMP%\%TYFILE%	echo #import "@preview/callisto:0.3.0"
>>%TEMP%\%TYFILE%	echo #import "@local/callisto-unmargin:0.1.0": unmargin-theme
>>%TEMP%\%TYFILE%	echo #import "@preview/tschich:0.2.0": *
>>%TEMP%\%TYFILE%	echo #import "@local/neat-document:0.1.0": neat-document
>>%TEMP%\%TYFILE%	echo #set document(title: [^<DUMMY^>])
>>%TEMP%\%TYFILE%	echo #show: neat-document.with(lang: "ru", margin: tschich-var(210mm, 297mm, 1 / 12))
>>%TEMP%\%TYFILE%	echo #let (render, Cell, In, Out) = callisto.config(
>>%TEMP%\%TYFILE%	echo   nb: path("<DUMMY>.ipynb"),
>>%TEMP%\%TYFILE%	echo   handlers: (path: (x, ..args) =^> path(x)),
>>%TEMP%\%TYFILE%	echo   theme: unmargin-theme,
>>%TEMP%\%TYFILE%	echo )
>>%TEMP%\%TYFILE%	echo #render()
goto :EOF
