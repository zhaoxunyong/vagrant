//https://msdn.microsoft.com/en-us/library/windows/desktop/gg537745(v=vs.85).aspx
//https://stackoverflow.com/questions/5944180/how-do-you-run-a-command-as-an-administrator-from-the-windows-command-line
//@if (1==1) @if(1==0) @ELSE
//@echo off&SETLOCAL ENABLEEXTENSIONS
//>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"||(
//    cscript //E:JScript //nologo "%~f0"
//    @goto :EOF
//)
//echo.Performing admin tasks...
//REM call foo.exe
//@goto :EOF
//@end @ELSE
ShA=new ActiveXObject("Shell.Application")
// ShA.ShellExecute("cmd.exe","/c \""+WScript.ScriptFullName+"\"","","runas",5);
ShA.ShellExecute("vagrant.exe","up","","runas");
//@end