@echo off
cls
setlocal
:prep 
echo Preparing...
mkdir temp
echo Checking for WINRAR Command Line...
call :download dummy.rar a.rar check
:check
unrar e "%cd%\temp\a.rar">nul 2>&1 && (
    echo WINRAR detected.
    set m=rar
) || (
    echo WINRAR not detected. Will use ZIP method.
    set m=zip
)
del "%cd%\temp\a.rar"
echo Downloading PTR2Tools respository... 
call :download %m%/ptr2tools-master.%m% PTR2Tools.%m% eptr2tools
:: bitsadmin /transfer "ptr2helper" https://rawgit.com/MGRich/ptr2helper/master/%m%/ptr2tools-master.%m% "%cd%\temp\PTR2Tools.%m%">nul
:eptr2tools
echo Done.
echo Extracting PTR2Tools...
if %m% EQU zip (call :unzip "%cd%\temp" "%cd%\temp\PTR2Tools.%m%") ELSE (unrar x "%cd%\temp\PTR2Tools.%m%" *.* "%cd%\temp")
echo Done.
echo Downloading DLLs (this can take a while)... 
call :download %m%/dll.%m% dll.%m% edlls
:: bitsadmin /transfer "ptr2helper" https://rawgit.com/MGRich/ptr2helper/master/%m%/ptr2tools-master.%m% "%cd%\temp\PTR2Tools.%m%">nul
:edlls
echo Done.
echo Extracting DLLs...
if %m% EQU zip (call :unzip "%cd%\temp" "%cd%\temp\dll.%m%") ELSE (unrar x "%cd%\temp\dll.%m%" *.* "%cd%\temp\dll")
echo Done.
pause
echo Temporarily downloading and installing win-bash (might take a while)...
bitsadmin /transfer "winbash" "https://downloads.sourceforge.net/project/win-bash/shell-complete/latest/shell.w32-ix86.zip" "%cd%\temp\win-bash.zip">nul
call :unzip "%cd%\temp\win-bash" "%cd%\temp\win-bash.zip" 
set path="%path%;%cd%\temp\win-bash"
echo Compiling PTR2Tools...
cd "temp\ptr2tools-master"
sh make.sh>nul
cd ..
cd ..
echo Done.
echo Installing PTR2Tools...
cd pdir="%cd%\temp\ptr2tools-master\sources"
mkdir ptr2tools
xcopy /y "%pdir%\ptr2int\ptr2int.exe" "ptr2tools"
xcopy /y "%pdir%\ptr2tex\ptr2tex.exe" "ptr2tools"
xcopy /y "%pdir%\ptr2spm\ptr2spm.exe" "ptr2tools"
:download <file> <output> <label>
bitsadmin /transfer "download" "https://rawgit.com/MGRich/ptr2helper/master/%1" "%cd%\temp\%2">nul
goto %3
:unzip <extracc> <insertt>
set vbs="%cd%\temp\unzip.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%