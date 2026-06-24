@echo off
setlocal

set "PATH=C:\Borland\bcc58\Bin;C:\MiniGUI\Harbour\bin;%PATH%"
set "HB_COMPILER=bcc"

:: Executa a compilação enviando a saída para o filtro FINDSTR, eliminando linhas que contenham "Warning" 
C:\MiniGUI\Harbour\bin\hbmk2.exe demo_office365.prg hbnfeemail.prg -comp=bcc -lhbwin -q -w0 2>&1 | findstr /V /I /C:"Warning"

pause
endlocal 

