[Setup]
AppName=FolioHaven (Flutter)
AppVersion=1.0.0
DefaultDirName={autopf}\FolioHaven Flutter
DefaultGroupName=FolioHaven Flutter
OutputDir=C:\Users\epicg\Downloads
OutputBaseFilename=FolioHaven-Flutter-1.0.0-Setup-Windows-x64
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "C:\Users\epicg\Downloads\FolioHaven-Flutter-Windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\FolioHaven (Flutter)"; Filename: "{app}\foliohaven_flutter.exe"
Name: "{autodesktop}\FolioHaven (Flutter)"; Filename: "{app}\foliohaven_flutter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\foliohaven_flutter.exe"; Description: "{cm:LaunchProgram,FolioHaven}"; Flags: nowait postinstall skipifsilent
