@echo off
for %%a in (%*) do glualint --pretty-print-files %%a
pause