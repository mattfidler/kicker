@echo off
rem See http://forums.fofou.org/sumatrapdf/topic?id=2140330
rem the dash %~1 removes stupid quotation marks
set PDF_FILE="%CD%\%~1"
set TEX_FILE="%CD%\%~2"
set LINE_IN_TEX=%3
set DDECLIENT=ddeclient.exe
set SUMATRA=sumatrapdf.exe

for %%x in (%DDECLIENT% %SUMATRA%) do if [%%~$PATH:x]==[] (
echo %%x is not in your PATH.
echo %%x is not in your PATH. > %TEMP%\msg.txt
notepad %TEMP%\msg.txt
del %TEMP%\msg.txt
goto exit
)

start %SUMATRA% -reuse-instance %PDF_FILE% -inverse-search "emacsclientw.exe +%%l \"%%f\" --server-file \"%EMACS_SERVER_FILE%\""
echo [ForwardSearch(%PDF_FILE%,%TEX_FILE%,%LINE_IN_TEX%,0,0,1)] | %DDECLIENT% SUMATRA control

:exit