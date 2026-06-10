@echo off
setlocal EnableExtensions

:: Run from the directory containing this script
pushd "%~dp0"

set "TRIPLE=x86_64-unknown-windows-msvc"
set "VERSION=v1.3.11"

set "ROOT=%CD%"
set "SRC=%ROOT%\cminpack"
set "BUILD=%ROOT%\build\%TRIPLE%"
set "STAGE=%ROOT%\stage\%TRIPLE%"

set "BUNDLE=%ROOT%\..\CMinpack.artifactbundle"
set "INCLUDE_DST=%BUNDLE%\include"
set "LIB_DST=%BUNDLE%\lib\x86_64-unknown-windows-msvc"

set "CMINPACK_INCLUDE_SRC=%STAGE%\include\cminpack-1"
set "CMINPACK_LIB_SRC=%STAGE%\lib"

echo Cleaning previous temporary directories...
if exist "%SRC%" rmdir /S /Q "%SRC%"
if exist "%ROOT%\build" rmdir /S /Q "%ROOT%\build"
if exist "%ROOT%\stage" rmdir /S /Q "%ROOT%\stage"

echo Creating artifact bundle directories...
if not exist "%INCLUDE_DST%" mkdir "%INCLUDE_DST%"
if not exist "%LIB_DST%" mkdir "%LIB_DST%"

echo Cloning cminpack...
git clone --branch "%VERSION%" --single-branch https://github.com/devernay/cminpack "%SRC%"
if errorlevel 1 goto fail

echo Configuring cminpack...
cmake -S "%SRC%" -B "%BUILD%" ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%STAGE%" ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMINPACK_PRECISION=d ^
  -DUSE_BLAS=OFF ^
  -DCMAKE_C_COMPILER=clang-cl
if errorlevel 1 goto fail

echo Building cminpack...
cmake --build "%BUILD%" --config Release
if errorlevel 1 goto fail

cmake --install "%BUILD%" --config Release
if errorlevel 1 goto fail

echo Installed files:
dir /S /B "%STAGE%"

echo Copying headers and static library...

copy /Y "%CMINPACK_INCLUDE_SRC%\cminpack.h" "%INCLUDE_DST%\"
if errorlevel 1 goto fail

copy /Y "%CMINPACK_INCLUDE_SRC%\minpack.h" "%INCLUDE_DST%\"
if errorlevel 1 goto fail

copy /Y "%CMINPACK_LIB_SRC%\cminpack_s.lib" "%LIB_DST%\"
if errorlevel 1 goto fail
  
echo Cleaning temporary directories...
if exist "%SRC%" rmdir /S /Q "%SRC%"
if exist "%ROOT%\build" rmdir /S /Q "%ROOT%\build"
if exist "%ROOT%\stage" rmdir /S /Q "%ROOT%\stage"

echo Done.
popd
exit /B 0

:fail

echo %INCLUDE_DST%
echo %LIB_DST%
echo.
echo Build or copy failed. Temporary directories were left in place for debugging.
popd
exit /B 1