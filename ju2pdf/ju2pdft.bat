chcp 65001
cls

if not exist ".ipynb" mkdir ".ipynb"
if not exist "Семинары\pdf" mkdir "Семинары\pdf"
if not exist ".ipynb\.pics" mklink /J ".ipynb\.pics" "Семинары\.pics"

uv run jupyter nbconvert --execute --allow-errors --to notebook --output-dir=".ipynb" "Семинары\%~n1.ipynb"
copy ju2pdft.typ ".ipynb\%~n1.typ"
py ju2pdft.py "%~n1"
typst c ".ipynb\%~n1.typ"
copy ".ipynb\%~n1.pdf" "Семинары\pdf\%~n1.pdf"
