@echo off

set DebugBuild=0
set SourceDirectory=../src

set OutputDirectory=release
if "%DebugBuild%"=="1" (
	set OutputDirectory=debug
)
mkdir %OutputDirectory% 2> NUL

rem call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
rem call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64 -no_logo
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64

set CompilerFlags=/DLUA_COMPAT_5_3
rem /FC = Full path for error messages
rem /EHsc = Exception Handling Model: Standard C++ Stack Unwinding. Functions declared as extern "C" can't throw exceptions
rem /EHa- = TODO: Do we really need this?? It seems like this option should be off if we specify s and c earlier
rem /nologo = Suppress the startup banner
rem /GS- = Buffer overrun protection is turned off
rem /Gm- = Minimal rebuild is enabled [deprecated]
rem /GR- = Run-Time Type Information is Disabled [_CPPRTTI macro doesn't work]
rem /WX = Treat warnings as errors
rem /W4 = Warning level 4 [just below /Wall]
set CompilerFlags=%CompilerFlags% /FC /EHsc /EHa- /nologo /GS- /Gm- /GR- /WX /W4 /Fd"%OutputDirectory%\lua.pdb"
rem warning C4244: '=': conversion from 'int' to 'lu_byte', possible loss of data
rem warning C4310: cast truncates constant value
rem warning C4702: unreachable code
rem warning C4324: 'lua_longjmp': structure was padded due to alignment specifier
rem warning C4701: potentially uninitialized local variable 'n1' used
set CompilerFlags=%CompilerFlags% /wd4244 /wd4310 /wd4702 /wd4324 /wd4701
rem gdi32.lib User32.lib Shell32.lib kernel32.lib
set Libraries=
set LinkerFlags=/MACHINE:X64 /NOLOGO /OUT:"%OutputDirectory%\lua.lib"
set IncludeFolders=/I"%SourceDirectory%"

if "%DebugBuild%"=="1" (
	rem /Od = Optimization level: Debug
	rem /Zi = Generate complete debugging information
	rem /MTd = Statically link the standard library [not as a DLL, Debug version]
	set CompilerFlags=%CompilerFlags% /Od /Zi /MTd
) else (
	rem /Ot = Favors fast code over small code
	rem /Oy = Omit frame pointer [x86 only]
	rem /O2 = Optimization level 2: Creates fast code
	rem /MT = Statically link the standard library [not as a DLL]
	rem /Zi = Generate complete debugging information [optional]
	set CompilerFlags=%CompilerFlags% /Ot /Oy /O2 /MT /Zi
)

echo [Compiling... %OutputDirectory%]
set ObjectFiles=

rem +--------------------------------------------------------------+
rem |                          Core Files                          |
rem +--------------------------------------------------------------+
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lapi.obj"     "%SourceDirectory%\lapi.c"     & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lapi.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lcode.obj"    "%SourceDirectory%\lcode.c"    & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lcode.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lctype.obj"   "%SourceDirectory%\lctype.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lctype.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ldebug.obj"   "%SourceDirectory%\ldebug.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ldebug.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ldo.obj"      "%SourceDirectory%\ldo.c"      & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ldo.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ldump.obj"    "%SourceDirectory%\ldump.c"    & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ldump.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lfunc.obj"    "%SourceDirectory%\lfunc.c"    & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lfunc.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lgc.obj"      "%SourceDirectory%\lgc.c"      & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lgc.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\llex.obj"     "%SourceDirectory%\llex.c"     & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\llex.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lmem.obj"     "%SourceDirectory%\lmem.c"     & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lmem.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lobject.obj"  "%SourceDirectory%\lobject.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lobject.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lopcodes.obj" "%SourceDirectory%\lopcodes.c" & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lopcodes.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lparser.obj"  "%SourceDirectory%\lparser.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lparser.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lstate.obj"   "%SourceDirectory%\lstate.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lstate.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lstring.obj"  "%SourceDirectory%\lstring.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lstring.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ltable.obj"   "%SourceDirectory%\ltable.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ltable.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ltm.obj"      "%SourceDirectory%\ltm.c"      & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ltm.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lundump.obj"  "%SourceDirectory%\lundump.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lundump.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lvm.obj"      "%SourceDirectory%\lvm.c"      & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lvm.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lzio.obj"     "%SourceDirectory%\lzio.c"     & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lzio.obj"

rem +--------------------------------------------------------------+
rem |                        Library Files                         |
rem +--------------------------------------------------------------+
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lauxlib.obj"  "%SourceDirectory%\lauxlib.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lauxlib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lbaselib.obj" "%SourceDirectory%\lbaselib.c" & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lbaselib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lcorolib.obj" "%SourceDirectory%\lcorolib.c" & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lcorolib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ldblib.obj"   "%SourceDirectory%\ldblib.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ldblib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\liolib.obj"   "%SourceDirectory%\liolib.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\liolib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lmathlib.obj" "%SourceDirectory%\lmathlib.c" & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lmathlib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\loadlib.obj"  "%SourceDirectory%\loadlib.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\loadlib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\loslib.obj"   "%SourceDirectory%\loslib.c"   & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\loslib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lstrlib.obj"  "%SourceDirectory%\lstrlib.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lstrlib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\ltablib.obj"  "%SourceDirectory%\ltablib.c"  & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\ltablib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\lutf8lib.obj" "%SourceDirectory%\lutf8lib.c" & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\lutf8lib.obj"
cl /c %CompilerFlags% %IncludeFolders% /Fo"%OutputDirectory%\linit.obj"    "%SourceDirectory%\linit.c"    & set ObjectFiles=%ObjectFiles% "%OutputDirectory%\linit.obj"

echo [Linking...]
LINK /lib %LinkerFlags% %ObjectFiles% %Libraries%
echo [Done!]

del %OutputDirectory%\*.obj > NUL 2> NUL
