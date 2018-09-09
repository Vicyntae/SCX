ScriptName SCX_SpellBookTeach Extends ObjectReference

Actor Property PlayerRef Auto
Spell[] Property Settings_AddSpells Auto
Event OnRead()
  Int i = Settings_AddSpells.Length
  While i
    i -= 1
    If Settings_AddSpells[i] && !PlayerRef.HasSpell(Settings_AddSpells[i])
      PlayerRef.AddSpell(Settings_AddSpells[i], True)
    EndIf
  EndWhile
EndEvent
