:: Gen: gen_vc.cmd -nocrt -ansi -xp -con ..\src\mcrt.c ..\src\explorertools.c -x64 -link /out:..\bin\et64.exe
@echo off
setlocal


::
:: INIT XP TOOLCHAIN
::


set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
path %SDK71PATH%\Bin\x64;%PATH%
set INCLUDE=%INCLUDE%;%SDK71PATH%\Include
set LIB=%LIB%;%SDK71PATH%\Lib\x64


::
:: INIT VC++ COMPILER
::


:TRY_INIT_VS2017
:: VS150COMNTOOLS_fix.cmd
:: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
if not exist "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" goto :TRY_INIT_VS2015
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" x64
goto :BUILD

:TRY_INIT_VS2015
:: VS140COMNTOOLS_in_VS2017_fix.reg
:: https://gist.github.com/Ruzzz/38dc70f4b850dd5e379f8cfa2cbf09a3
if not exist "%VS140COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat" goto :TRY_INIT_VS2013
call "%VS140COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
goto :BUILD

:TRY_INIT_VS2013
if not exist "%VS120COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat" goto :TRY_INIT_VS2012
call "%VS120COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
goto :BUILD

:TRY_INIT_VS2012
if not exist "%VS110COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat" goto :TRY_INIT_VS2010
call "%VS110COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
goto :BUILD

:TRY_INIT_VS2010
if not exist "%VS100COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat" goto :TRY_INIT_VS2008
call "%VS100COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
goto :BUILD

:TRY_INIT_VS2008
if not exist "%VS90COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat" goto :ERROR
call "%VS90COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
goto :BUILD


::
:: BUILD
::


:BUILD
if ERRORLEVEL 1 goto :ERROR
set CL=/W4 /MT /GF /D NDEBUG /D WIN32 /D _WINDOWS /O1 /GS- /EHsa- /D NOCRT /D_USING_V110_SDK71_
set LINK=/OPT:REF /OPT:ICF /MACHINE:X64 /DYNAMICBASE:NO /NXCOMPAT:NO /FIXED /NODEFAULTLIB /MERGE:.rdata=.text /ENTRY:main /SUBSYSTEM:CONSOLE,5.02
cl.exe /nologo kernel32.lib user32.lib shell32.lib advapi32.lib ole32.lib ..\src\mcrt.c ..\src\explorertools.c /link /nologo /out:..\bin\et64.exe
if ERRORLEVEL 1 goto :ERROR
del *.obj>nul
endlocal
exit 0

:ERROR
endlocal
set ERRORLEVEL=%ERRORLEVEL%
pause
del *.obj>nul
exit %ERRORLEVEL%
