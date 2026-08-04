; ============================================================
; NexLedger — Inno Setup Installer Script
; Version: 1.0.0
; Usage: Open this file in Inno Setup Compiler on Windows
;        AFTER extracting NexLedger_Windows_Release.zip
; ============================================================

#define MyAppName      "NexLedger"
#define MyAppVersion   "1.0.0"
#define MyAppPublisher "Aldrich Energy"
#define MyAppExeName   "nex_ledger.exe"
; Path to your extracted Release folder (edit this if needed)
#define MySourceDir    "Release"

[Setup]
; Unique App ID — do NOT change this after first release (used for upgrades)
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}

; Install into C:\Users\<user>\AppData\Local\NexLedger (no admin needed)
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}

; Allow user to change install dir
DisableDirPage=no

; Output settings
OutputDir=Output
OutputBaseFilename=NexLedger_Setup_v1.0.0

; Compression (maximum)
Compression=lzma2/max
SolidCompression=yes

; Minimum Windows version: Windows 10
MinVersion=10.0

; No admin rights needed (runs as current user)
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
; Desktop shortcut — checked by default
Name: "desktopicon"; Description: "Create a &Desktop shortcut for NexLedger"; GroupDescription: "Additional icons:"; Flags: checkedonce

; Start Menu shortcut
Name: "startmenuicon"; Description: "Add NexLedger to the Start &Menu"; GroupDescription: "Additional icons:"; Flags: checkedonce

[Files]
; Copy everything from the Release folder (exe + all DLLs + data folder)
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Start Menu shortcuts
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

; Desktop shortcut (only if task selected)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Offer to launch NexLedger after installation finishes
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName} now"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Clean up install folder on uninstall
Type: filesandordirs; Name: "{app}"

[Code]
// Show a friendly message when installation completes
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    MsgBox(
      'NexLedger v1.0.0 has been installed successfully!' + #13#10 + #13#10 +
      'Your project data (database) is safely stored in:' + #13#10 +
      ExpandConstant('{localappdata}') + '\NexLedger\nexledger.db' + #13#10 + #13#10 +
      'This database file is NEVER deleted when you update or reinstall NexLedger.' + #13#10 +
      'Your data is always safe!',
      mbInformation,
      MB_OK
    );
  end;
end;
