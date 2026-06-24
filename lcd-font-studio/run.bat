@echo off
cd /d "%~dp0"
python -c "import PIL" 2>nul || (
  echo Installing Pillow...
  pip install -r requirements.txt
)
python main.py
pause
