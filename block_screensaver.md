##📝 1. 스크립트 저장
예를 들어, 아래 내용을 KeepAlive.ps1로 저장합니다:
```
$wshell = New-Object -ComObject wscript.shell

while ($true) {
    Start-Sleep -Seconds 59
    $wshell.SendKeys("{SCROLLLOCK}{SCROLLLOCK}")
}
```
저장 경로 예시: C:\Scripts\KeepAlive.ps1

##🛡️2. 관리자 권한으로 실행하는 명령어
아래 명령어를 명령 프롬프트(cmd) 또는 다른 PowerShell 창에서 실행하면 됩니다:
```
Start-Process powershell -Verb runAs -ArgumentList "-ExecutionPolicy Bypass -File 'E:\block_screen_lock.ps1'"
```
-Verb runAs: 관리자 권한으로 실행

-ExecutionPolicy Bypass: 실행 정책 무시 (스크립트 실행 허용)

'C:\Scripts\KeepAlive.ps1': 스크립트 경로

실행 시 UAC(사용자 계정 컨트롤) 창이 뜨면 "예" 를 눌러 관리자 권한을 승인해야 합니다.

##⚙️3. 실행 정책이 막혀 있다면?
PowerShell에서 실행 정책을 확인하고 변경할 수 있습니다:
```
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
관리자 권한으로 실행해야 변경이 적용됩니다. RemoteSigned는 로컬 스크립트는 허용하고, 인터넷에서 받은 스크립트는 서명 필요합니다.
