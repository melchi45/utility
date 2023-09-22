A simple VBScript that will stop a computer from going to screen saver or lock screen

```
' Multiple references were used to create this, but the closest is:
' https://gallery.technet.microsoft.com/scriptcenter/Stop-locking-computer-by-3d6e2ac2
Set ws = WScript.CreateObject("WScript.Shell")    
Do  
  'Every 10 minutes should do
  Wscript.Sleep (1000 * 60 * 10)
  ws.sendkeys("{NUMLOCK}{NUMLOCK}")
Loop
```
