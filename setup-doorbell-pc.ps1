# ตั้งค่าให้ "กริ่งประตู (ตัวรับ)" เปิดอัตโนมัติตอน login Windows
# ใช้กับ PC เครื่องไหนก็ได้ที่มี Chrome หรือ Edge
$ErrorActionPreference = "Stop"
$url = "https://witchupang.github.io/doorbell/"
$dataDir = Join-Path $env:LocalAppData "DoorbellReceiver"

# หาเบราว์เซอร์ (Chrome ก่อน แล้ว Edge)
$cands = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$browser = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { Write-Host "Chrome/Edge not found."; Read-Host "Press Enter"; exit 1 }

$arguments = "--app=$url --user-data-dir=`"$dataDir`" --autoplay-policy=no-user-gesture-required --no-first-run --no-default-browser-check"

# สร้าง shortcut ในโฟลเดอร์ Startup
$startup = [Environment]::GetFolderPath('Startup')
$lnkPath = Join-Path $startup "Doorbell Receiver.lnk"
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath  = $browser
$lnk.Arguments   = $arguments
$lnk.IconLocation = "$browser,0"
$lnk.Description  = "Doorbell receiver - auto start on login"
$lnk.Save()

Write-Host "OK: auto-start set up using $browser"
Write-Host "Opening the receiver now for first-time setup..."
Start-Process $browser -ArgumentList $arguments
Write-Host ""
Write-Host "In the window that opened:"
Write-Host "  1) Click the gear, set Topic = bell-fqfPJoCW6HtCJvFF, Save"
Write-Host "  2) Click the page once and Allow notifications"
Read-Host "Then press Enter here to finish"
