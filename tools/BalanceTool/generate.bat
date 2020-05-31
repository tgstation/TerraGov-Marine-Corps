@echo off
echo Installing requirements...
python -m pip install -r requirements.txt
python generate.py
pause
