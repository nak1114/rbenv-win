Option Explicit

Dim objws
Dim objfs
Set objws = WScript.CreateObject("WScript.Shell")
Set objfs = CreateObject("Scripting.FileSystemObject")

Dim strCurrent
Dim strRbenvHome
Dim strDirCache
Dim strDirVers
Dim strDirLibs
strCurrent   = objfs.GetAbsolutePathName(".")
strRbenvHome = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strDirCache  = strRbenvHome & "\install_cache"
strDirVers   = strRbenvHome & "\versions"
strDirLibs   = strRbenvHome & "\libexec"

Function IsVersion(version)
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Function GetCurrentVersionGlobal()
    GetCurrentVersionGlobal = Null

    Dim fname
    Dim objFile
    fname = strRbenvHome & "\version"
    If objfs.FileExists( fname ) Then
        Set objFile = objfs.OpenTextFile(fname)
        If objFile.AtEndOfStream <> True Then
           GetCurrentVersionGlobal = Array(objFile.ReadLine,fname)
        End If
        objFile.Close
    End If
End Function

Function GetCurrentVersionLocal(path)
    GetCurrentVersionLocal = Null

    Dim fname
    Dim objFile
    Do While path <> ""
        fname = path & "\.rbenv_version"
        If objfs.FileExists( fname ) Then
            Set objFile = objfs.OpenTextFile(fname)
            If objFile.AtEndOfStream <> True Then
               GetCurrentVersionLocal = Array(objFile.ReadLine,fname)
            End If
            objFile.Close
            Exit Function
        End If
        path = objfs.getParentFolderName(path)
    Loop
End Function

Function GetCurrentVersionShell()
    GetCurrentVersionShell = Null

    Dim str
    str=objws.ExpandEnvironmentStrings("%RBENV_VERSION%")
    If str <> "%RBENV_VERSION%" Then
        GetCurrentVersionShell = Array(str,"%RBENV_VERSION%")
    End If
End Function

Function GetCurrentVersion()
    Dim str
    str=GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    If IsNull(str) Then Err.Raise vbError + 1, "version not found", "please set 'rbenv global <version>'"
    GetCurrentVersion = str
End Function

Function GetCurrentVersionNoError()
    Dim str
    str=GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Function GetBinDir(ver)
    Dim str
    str=strDirVers & "\" & ver & "\bin" 
    If Not(IsVersion(ver) And objfs.FolderExists(str)) Then Err.Raise vbError + 2, "rbenv", "version `"&ver&"' not installed"
    GetBinDir = str
End Function

Function GetCommandList()
    Dim cmdList
    Set cmdList = CreateObject("scripting.dictionary")'"System.Collections.SortedList"

    Dim re
    Set re = new regexp
    re.Pattern = "\\rbenv-([a-zA-Z_0-9-]+)\.(bat|vbs)$"

    Dim file
    Dim mts
    For Each file In objfs.GetFolder(strDirLibs).Files
        Set mts=re.Execute(file)
        If mts.Count > 0 Then
             cmdList.Add mts(0).submatches(0), file
        End If
    Next

    Set GetCommandList = cmdList
End Function

Sub ExecCommand(str)
    Dim ofile
    Set ofile = objfs.CreateTextFile(strRbenvHome & "\exec.bat" , True )
    ofile.WriteLine(str)
    ofile.Close()
End Sub

Sub ShowHelp()
     Wscript.echo "Usage: rbenv <command> [<args>]"
     Wscript.echo ""
     Wscript.echo "Some useful rbenv commands are:"
     Wscript.echo "   commands    List all available rbenv commands"
     Wscript.echo "   local       Set or show the local application-specific Ruby version"
     Wscript.echo "   global      Set or show the global Ruby version"
     Wscript.echo "   shell       Set or show the shell-specific Ruby version"
     Wscript.echo "   install     Install a Ruby version using ruby-build"
     Wscript.echo "   uninstall   Uninstall a specific Ruby version"
     Wscript.echo "   rehash      Rehash rbenv shims (run this after installing executables)"
     Wscript.echo "   version     Show the current Ruby version and its origin"
     Wscript.echo "   versions    List all Ruby versions available to rbenv"
     Wscript.echo "   exec        Runs an executable by first preparing PATH so that the selected Ruby"
     Wscript.echo ""
     Wscript.echo "See `rbenv help <command>' for information on a specific command."
     Wscript.echo "For full documentation, see: https://github.com/rbenv/rbenv#readme"
     Exit Sub


     Wscript.echo "   which       Display the full path to an executable"
     Wscript.echo "   whence      List all Ruby versions that contain the given executable"
End Sub

Sub CommandHelp(arg)
    If arg.Count > 1 Then
        Dim list
        Set list=GetCommandList
        If list.ContainsKey(arg(1)) Then
            ExecCommand(list(arg(1)) & " --help")
        Else
             Wscript.echo "unknown rbenv command '"&arg(1)&"'"
        End If
    Else
        ShowHelp
    End If
End Sub


Sub CommandRehash(arg)
    Dim strDirShims
    strDirShims= strRbenvHome & "\shims"
    If Not objfs.FolderExists( strDirShims ) Then objfs.CreateFolder(strDirShims)

    Dim ofile
    Dim file
    For Each file In objfs.GetFolder(strDirShims).Files
        objfs.DeleteFile file, True
    Next
    For Each file In objfs.GetFolder(GetBinDir(GetCurrentVersion()(0))).Files
        If objfs.GetExtensionName(file) = "exe" or objfs.GetExtensionName(file) = "bat" Then
          Set ofile = objfs.CreateTextFile(strDirShims & "\" & objfs.GetBaseName( file ) & ".bat" )
          ofile.WriteLine("@echo off")
          ofile.WriteLine("rbenv exec %~n0 %*")
          ofile.Close()
        End If
    Next
End Sub

Sub CommandExecute(arg)
    Dim str
    Dim dstr
    dstr=GetBinDir(GetCurrentVersion()(0))
    str="set PATH=" & dstr & ";%PATH%" & vbCrLf
    If arg.Count > 1 Then  
      str=str & """" & dstr & "\" & arg(1) & """"
      Dim idx
      If arg.Count > 2 Then  
        For idx = 2 To arg.Count - 1 
          str=str & " """& arg(idx) &""""
        Next
      End If
    End If
    ExecCommand(str)
End Sub

Sub CommandGlobal(arg)
    If arg.Count < 2 Then  
        Dim ver
        ver=GetCurrentVersionGlobal()
        If IsNull(ver) Then
            Wscript.echo "no global version configured"
        Else
            Wscript.echo ver(0)
        End If
    Else
        GetBinDir(arg(1))
        Dim ofile
        Set ofile = objfs.CreateTextFile( strRbenvHome & "\version" , True )
        ofile.WriteLine(arg(1))
        ofile.Close()
    End If
End Sub

Sub CommandLocal(arg)
    Dim ver
    If arg.Count < 2 Then  
        ver=GetCurrentVersionLocal(strCurrent)
        If ver = Null Then
            Wscript.echo "no local version configured for this directory"
        Else
            Wscript.echo ver(0)
        End If
    Else
        ver=arg(1)
        If ver = "--unset" Then
            ver = ""
            objFSO.DeleteFile strDelFile, True
        Else
            GetBinDir(ver)
        End If
        Dim ofile
        Set ofile = objfs.CreateTextFile( strCurrent & "\.rbenv_version" , True )
        ofile.WriteLine(ver)
        ofile.Close()
    End If
End Sub

Sub CommandShell(arg)
    Dim ver
    If arg.Count < 2 Then  
        ver=GetCurrentVersionShell
        If ver = Null Then
            Wscript.echo "no shell-specific version configured"
        Else
            Wscript.echo ver(0)
        End If
    Else
        ver=arg(1)
        If ver = "--unset" Then
            ver = ""
        Else
            GetBinDir(ver)
        End If
        ExecCommand("endlocal"&vbCrLf&"set RBENV_VERSION=" & ver)
    End If
End Sub

Sub CommandVersion(arg)
    If Not objfs.FolderExists( strDirVers ) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer=GetCurrentVersion
    Wscript.echo curVer(0) & " (set by " &curVer(1)&")"
End Sub

Sub CommandVersions(arg)
    Dim isBare

    isBare=False
    If arg.Count > 2 Then
        If arg(1) = "--bare" Then isBare=True
    End If

    If Not objfs.FolderExists( strDirVers ) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer=GetCurrentVersionNoError
    If IsNull(curVer) Then
        curVer=Array("","")
    End If

    Dim dir
    Dim ver
    For Each dir In objfs.GetFolder(strDirVers).subfolders
        ver=objfs.GetFileName( dir )
        If isBare Then
            Wscript.echo ver
        ElseIf ver = curVer(0) Then
            Wscript.echo "* " & ver & " (set by " &curVer(1)&")"
        Else
            Wscript.echo "  " & ver
        End If
    Next
End Sub

Sub PlugIn(arg)
    Dim fname
    Dim idx
    Dim str
    fname = strDirLibs & "\rbenv-" & arg(0)
    If objfs.FileExists( fname & ".bat" ) Then
        str="""" & fname & ".bat"""
    ElseIf objfs.FileExists( fname & ".vbs" ) Then
        str="cscript //nologo """ & fname & ".vbs"""
    Else
       Wscript.echo "rbenv: no such command `"&arg(0)&"'"
       Wscript.Quit
    End If

    For idx = 1 To arg.Count - 1 
      str=str & " """& arg(idx) &""""
    Next

    ExecCommand(str)
End Sub

Sub CommandCommands(arg)
    Dim cname
    For Each cname In GetCommandList()
        Wscript.echo cname
    Next
End Sub

Sub Dummy()
     Wscript.echo "command not implement"
End Sub


Sub main(arg)
    If arg.Count = 0 Then
        ShowHelp
    Else
        Select Case arg(0)
           Case "exec"        CommandExecute(arg)
           Case "rehash"      CommandRehash(arg)
           Case "global"      CommandGlobal(arg)
           Case "local"       CommandLocal(arg)
           Case "shell"       CommandShell(arg)
           Case "version"     CommandVersion(arg)
           Case "versions"    CommandVersions(arg)
           Case "commands"    CommandCommands(arg)
           Case "help"        CommandHelp(arg)
           Case Else          PlugIn(arg)
        End Select
    End If
End Sub



main(WScript.Arguments)
