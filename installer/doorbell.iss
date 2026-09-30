; Inno Setup script — ตัวติดตั้ง "กริ่งประตู (Doorbell)" (PWA wrapper)
; ติดตั้งแบบ per-user (ไม่ต้อง admin) สร้าง shortcut เปิด Chrome/Edge เป็น app
; + ตัวเลือกเปิดอัตโนมัติตอน login + ลงทะเบียน uninstall

#define AppName "กริ่งประตู (Doorbell)"
#define AppVer "1.0.0"
#define Publisher "witchupanG"
#define DoorbellURL "https://witchupang.github.io/doorbell/"

[Setup]
AppId={{8F3C2A91-7E4D-4B6A-9C12-1A2B3C4D5E6F}
AppName={#AppName}
AppVersion={#AppVer}
AppPublisher={#Publisher}
DefaultDirName={autopf}\DoorbellReceiver
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=.
OutputBaseFilename=DoorbellReceiver-Setup
SetupIconFile=app_doorbell.ico
UninstallDisplayIcon={app}\app_doorbell.ico
UninstallDisplayName={#AppName}
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "app_doorbell.ico"; DestDir: "{app}"; Flags: ignoreversion

[Tasks]
Name: "desktopicon"; Description: "สร้างไอคอนบนเดสก์ท็อป (Desktop shortcut)"; GroupDescription: "ทางลัด (Shortcuts):"
Name: "startupicon"; Description: "เปิดตัวรับกริ่งอัตโนมัติเมื่อเข้า Windows (auto-start at login)"; GroupDescription: "เริ่มต้นอัตโนมัติ (Auto-start):"

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{code:GetBrowser}"; Parameters: "{code:GetArgs}"; IconFilename: "{app}\app_doorbell.ico"; Comment: "ตัวรับกริ่งประตู"
Name: "{autodesktop}\{#AppName}"; Filename: "{code:GetBrowser}"; Parameters: "{code:GetArgs}"; IconFilename: "{app}\app_doorbell.ico"; Tasks: desktopicon
Name: "{userstartup}\{#AppName}"; Filename: "{code:GetBrowser}"; Parameters: "{code:GetArgs}"; IconFilename: "{app}\app_doorbell.ico"; Tasks: startupicon

[Run]
Filename: "{code:GetBrowser}"; Parameters: "{code:GetArgs}"; Description: "เปิดตัวรับกริ่งตอนนี้ (ตั้ง Topic + อนุญาตการแจ้งเตือนครั้งแรก)"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{localappdata}\DoorbellReceiver"

[Code]
var
  BrowserPath: String;

function FindBrowser(): String;
var
  cands: array of String;
  i: Integer;
begin
  Result := '';
  SetArrayLength(cands, 6);
  cands[0] := ExpandConstant('{commonpf}\Google\Chrome\Application\chrome.exe');
  cands[1] := ExpandConstant('{commonpf32}\Google\Chrome\Application\chrome.exe');
  cands[2] := ExpandConstant('{localappdata}\Google\Chrome\Application\chrome.exe');
  cands[3] := ExpandConstant('{commonpf32}\Microsoft\Edge\Application\msedge.exe');
  cands[4] := ExpandConstant('{commonpf}\Microsoft\Edge\Application\msedge.exe');
  cands[5] := ExpandConstant('{localappdata}\Microsoft\Edge\Application\msedge.exe');
  for i := 0 to GetArrayLength(cands) - 1 do
  begin
    if FileExists(cands[i]) then
    begin
      Result := cands[i];
      Exit;
    end;
  end;
end;

function InitializeSetup(): Boolean;
begin
  BrowserPath := FindBrowser();
  if BrowserPath = '' then
  begin
    MsgBox('ไม่พบ Google Chrome หรือ Microsoft Edge บนเครื่องนี้' + #13#10 +
           'กรุณาติดตั้ง Chrome หรือ Edge ก่อน แล้วรันตัวติดตั้งนี้อีกครั้ง',
           mbError, MB_OK);
    Result := False;
  end
  else
    Result := True;
end;

function GetBrowser(Param: String): String;
begin
  Result := BrowserPath;
end;

function GetArgs(Param: String): String;
begin
  Result := '--app={#DoorbellURL} --user-data-dir="' +
            ExpandConstant('{localappdata}\DoorbellReceiver') + '"' +
            ' --autoplay-policy=no-user-gesture-required --no-first-run --no-default-browser-check';
end;
