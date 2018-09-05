ScriptName SCV_GameLibrary Extends SCX_BaseQuest

SCVSettings Property SCVSet Auto
SCVLibrary Property SCVLib Auto
SCX_ModConfigMenu Property MCM Auto

Function _setup()
  SCVSet.GameLibrary = Self
EndFunction
