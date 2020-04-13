@echo off
set /p changes="Enter Changes: "
"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe"  update -addon "TTT-Randomat-20.gma" -id "2055805086" -changes "%changes%"
pause