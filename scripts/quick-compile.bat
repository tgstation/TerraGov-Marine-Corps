echo off
setLocal EnableDelayedExpansion
cls

:: path to dm.exe
set dm= "C:\BYOND\bin\dm.exe"
:: path to .dme to compile
set dme= "C:\Users\Administrator\Desktop\ColonialMarinesALPHA\ColonialMarinesALPHA.dme"

start "" %dm% %dme%
