ShA=new ActiveXObject("Shell.Application")
// ShA.ShellExecute("cmd.exe","/c \""+WScript.ScriptFullName+"\"","","runas",5);
ShA.ShellExecute("vagrant.exe","halt","","runas");
