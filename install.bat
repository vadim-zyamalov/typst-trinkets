chcp 65001

if not exist %localappdata%\typst\packages\local (
	sudo mklink /D "%localappdata%\typst\packages\local" "%cd%\local"
)
