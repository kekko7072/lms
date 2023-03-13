[Setup]
AppId=522E4865-600A-44EE-A635-B31EE4E25742
AppVersion=0.0.6+7
AppName=LMS
AppPublisher=
AppPublisherURL=https://github.com/kekko7072/lms
AppSupportURL=https://github.com/kekko7072/lms
AppUpdatesURL=https://github.com/kekko7072/lms
DefaultDirName=LMS
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=lms-0.0.6+7-windows
Compression=lzma
SolidCompression=yes
SetupIconFile=
WizardStyle=modern
PrivilegesRequired=none
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
[Languages]

Name: "english"; MessagesFile: "compiler:Default.isl"







































Name: "italian"; MessagesFile: "compiler:Languages\\Italian.isl"











[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,LMS}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
[Files]
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\sqlite3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\dynamic_color_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\auto_updater_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\WinSparkle.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\franc\Desktop\lms\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
[Icons]
Name: "{autoprograms}\\LMS"; Filename: "{app}\\lms.exe"
Name: "{autodesktop}\\LMS"; Filename: "{app}\\lms.exe"; Tasks: desktopicon
Name: "{userstartup}\\LMS"; Filename: "{app}\\lms.exe"; WorkingDir: "{app}"; Tasks: launchAtStartup
[Run]
Filename: "{app}\\lms.exe"; Description: "{cm:LaunchProgram,LMS}"; Flags:  nowait postinstall skipifsilent