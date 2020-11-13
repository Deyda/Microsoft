# https://gist.github.com/AveYo/c74dc774a8fb81a332b5d65613187b15

@call :init  MediaCreationTool.bat - latest version at pastebin.com/bBw0Avc4 or git.io/MediaCreationTool.bat
:: Universal MCT wrapper script by AveYo - for all Windows 10 versions from 1507 to 20H2!
:: Nothing but Microsoft-hosted source links and no third-party tools - script just configures a xml and starts MCT!
:: Ingenious support for business editions (Enterprise / VL) selecting language, x86, x64 or AiO inside the MCT GUI!
:: Changelog: 2020.11.01
:: - script refactoring, clearer edition labels, new default options, hotfix utf-8, enterprise 1909+, fixed OPTIONS
:: - 2009: 19042.572 / 2004: 19041.508 / 1909: 18363.592 / 1903: 18362.356 / 1809: 17763.379 / 1803: 17134.112

set CHOICES= 1507, 1511, 1607, 1703, 1709, 1803, 1809, 1903 (19H1), 1909 (19H2), 2004 (20H1), 2009 (20H2)

:: Uncomment to unhide Enterprise / VL editions in products.xml that include them: 1709+
set/a UNHIDE_BUSINESS=1

:: Uncomment to insert Enterprise / VL editions in products.xml that never included them: 1607, 1703
set/a INSERT_BUSINESS=1

:: Uncomment to bypass gui dialog choice and hardcode the MCT version: 1=1507, 2=1511, 3=1607, ... 10=20H1, 11=20H2
rem set/a MCT_VERSION=11

:: Uncomment to force a specific Edition, Architecture and Language - if enabled, all 3 must be used
rem set OPTIONS=%OPTIONS% /MediaEdition Enterprise /MediaArch x64 /MediaLangCode en-us

:: Uncomment to force Auto Upgrade without user intervention - or just rename the script to "auto MediaCreationTool.bat"
rem set OPTIONS=%OPTIONS% /Eula Accept /MigChoice Upgrade /Auto Upgrade /Action UpgradeNow

:: Uncomment to disable dynamic update when doing upgrades
set OPTIONS=%OPTIONS% /DynamicUpdate Disable

:: Add / remove extra launch parameters below if needed - default preset gives the least amount of issues when doing upgrades
set OPTIONS=%OPTIONS% /Telemetry Disable /MigrateDrivers All /ResizeRecoveryPartition Disable /ShowOOBE None /Compat IgnoreWarning

:: Uncomment to use setup with uncompressed system files - Compact OS feature is more trouble than it's worth
set OPTIONS=%OPTIONS% /CompactOS Disable

:: Uncomment to use higher setup priority than default low
rem set OPTIONS=%OPTIONS% /Priority High

:: Uncomment to save MCT logs on script directory
set OPTIONS=%OPTIONS% /CopyLogs "%~dp0MCT"

:: Uncomment to enable shift+f10 cmd during oobe setup phase (1703+)
set OPTIONS=%OPTIONS% /DiagnosticPrompt enable

:: Uncomment to show live mct console log for debugging (1709+)
rem set OPTIONS=%OPTIONS% /Console

:: Handle auto upgrade scenario without user intervention when script was renamed to "auto MediaCreationTool.bat"
for /f %%/ in ("%~n0") do if /i %%/ EQU auto if not defined MCT_VERSION set MCT_VERSION=11

:: Show dialog w buttons: 1=outvar 2="choices" 3=selected     [optional:] 4="caption" 5=textsize 6=backcolor 7=textcolor 8=minsize
if not defined MCT_VERSION call :choices MCT_VERSION "%CHOICES%" 11 "Create Windows 10 Media" 13 white dodgerblue 300
if not defined MCT_VERSION %<%:f9 " NO MCT_VERSION SELECTED "%>% & timeout /t 5 >nul & exit/b

goto version-%MCT_VERSION%

:version-11
set "V=2009"
set "B=19042.572.201009-1947"
set "C=1.4.1"
set "CAB=http://download.microsoft.com/download/4/5/e/45eabe71-8b8f-487f-b591-314be20231d3/products_20201013.cab"
set "MCT=http://download.microsoft.com/download/4/c/c/4cc6c15c-75a5-4d1b-a3fe-140a5e09c9ff/MediaCreationTool20H2.exe"
:: just a 2004 with an integrated enablement package to activate many long-awaited usability and security fixes
goto process

:version-10
set "V=2004"
set "B=19041.508.200907-0256"
set "C=1.4"
set "CAB=http://download.microsoft.com/download/7/4/4/744ccd60-3203-4eea-bfa2-4d04e18a1552/products.cab"
set "MCT=http://software-download.microsoft.com/download/pr/MediaCreationTool2004.exe"
:: visible improvements to windows update, defender, search, dx12, wsl, sandbox; pushing ChrEdge intensifies
goto process

:version-9
set "V=1909"
set "B=18363.592.200109-2016"
set "C=1.3"
set "CAB=http://download.microsoft.com/download/8/2/b/82b12fa5-cab6-4d37-8167-16630c6151eb/products_20200116.cab"
set "MCT=http://download.microsoft.com/download/c/0/b/c0b2b254-54f1-42de-bfe5-82effe499ee0/MediaCreationTool1909.exe"
:: just a 1903 with an integrated enablement package to activate couple usability and security fixes
goto process

:version-8
set "V=1903"
set "B=18362.356.190909-1636"
set "C=1.3"
set "CAB=http://download.microsoft.com/download/4/e/4/4e491657-24c8-4b7d-a8c2-b7e4d28670db/products_20190912.cab"
set "MCT=http://software-download.microsoft.com/download/pr/MediaCreationTool1903.exe"
:: modern windows 10 starts here with proper memory allocation, cpu scheduling, security features
goto process

:version-7
set "V=1809"
set "B=17763.379.190312-0539"
set "C=1.3"
set "CAB=http://download.microsoft.com/download/8/E/8/8E852CBF-0BCC-454E-BDF5-60443569617C/products_20190314.cab"
set "MCT=http://software-download.microsoft.com/download/pr/MediaCreationTool1809.exe"
:: rather mediocre considering it is the base for ltsc 2019; less smooth than 1803 in games; (pre-Haswell Intel still bugged)
goto process

:version-6
set "V=1803"
set "B=17134.112.180619-1212"
set "C=1.2"
set "CAB=http://download.microsoft.com/download/5/C/B/5CB83D2A-2D7E-4129-9AFE-353F8459AA8B/products_20180705.cab"
set "MCT=http://software-download.microsoft.com/download/pr/MediaCreationTool1803.exe"
:: update available to finally fix most standby memory issues that were present since 1703 (pre-Haswell Intel still bugged)
goto process

:version-5
set "V=1709"
set "B=16299.125.171213-1220"
set "C=1.1"
set "CAB=http://download.microsoft.com/download/3/2/3/323D0F94-95D2-47DE-BB83-1D4AC3331190/products_20180105.cab"
set "MCT=http://download.microsoft.com/download/A/B/E/ABEE70FE-7DE8-472A-8893-5F69947DE0B1/MediaCreationTool.exe"
:: plagued by standby and other memory allocation bugs, fullscreen optimisation issues, by far the worst version of windows 10
goto process

:version-4
set "V=1703"
set "B=15063.0.170710-1358"
set "C=1.1"
set "XML=http://download.microsoft.com/download/2/E/B/2EBE3F9E-46F6-4DB8-9C84-659F7CCEDED1/products20170727.xml"
set "MCT=http://download.microsoft.com/download/1/C/4/1C41BC6B-F8AB-403B-B04E-C96ED6047488/MediaCreationTool.exe"
:: 1703 MCT executable is not working with customization atm so using 1709 instead
set "MCT=http://download.microsoft.com/download/A/B/E/ABEE70FE-7DE8-472A-8893-5F69947DE0B1/MediaCreationTool.exe"
:: some gamers still find this version the best despite unfixed memory allocation bugs and exposed cpu vulnerabilities
goto process

:version-3
set "V=1607"
set "B=14393.0.161119-1705"
set "C=1.0"
set "CAB=http://wscont.apps.microsoft.com/winstore/OSUpgradeNotification/MediaCreationTool/prod/Products_20170116.cab"
set "MCT=http://download.microsoft.com/download/C/F/9/CF9862F9-3D22-4811-99E7-68CE3327DAE6/MediaCreationTool.exe"
:: snappy and stable for legacy hardware, can still apply updates offline on any edition as it's the base for ltsb 2016
goto process

:version-2
set "V=1511"
set "B=10586.0.160426-1409"
set "C=1.0"
set "XML=http://wscont.apps.microsoft.com/winstore/OSUpgradeNotification/MediaCreationTool/prod/Products05242016.xml"
set "MCT=http://download.microsoft.com/download/1/C/4/1C41BC6B-F8AB-403B-B04E-C96ED6047488/MediaCreationTool.exe"
rem 1511 MCT exe works but without customization atm so using 1607 instead to show Education (no Enterprise esd)
:: other than a few using it for a license trick, not many ever missed this version; microsoft pulled it from MCT at one point
goto process

:version-1
set "V=1507"
set "B=10240.16393.150909-1450"
set "C=1.0"
set "XML=http://wscont.apps.microsoft.com/winstore/OSUpgradeNotification/MediaCreationTool/prod/Products09232015_2.xml"
set "MCT=http://download.microsoft.com/download/1/C/8/1C8BAF5C-9B7E-44FB-A90A-F58590B5DF7B/v2.0/MediaCreationToolx64.exe"
set "MCT32=http://download.microsoft.com/download/1/C/8/1C8BAF5C-9B7E-44FB-A90A-F58590B5DF7B/v2.0/MediaCreationTool.exe"
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" if not defined PROCESSOR_ARCHITEW6432 set "MCT=%MCT32%"
rem 1507 MCT exe works without customization atm so using 1511 instead (or 1607 + xml patch) to show Education (no Enterprise esd)
set "MCT=http://download.microsoft.com/download/1/C/4/1C41BC6B-F8AB-403B-B04E-C96ED6047488/MediaCreationTool.exe"
:: fastest for potato pc's
goto process

:process
for /f "tokens=1,2 delims=." %%m in ("%B%") do set build=%%m.%%n
%<%:f9 " Windows 10 Version "%>>%  &  %<%:5f " %V% "%>>%  &  %<%:f0 " %build% "%>>%  &  %<%:99 ~%>%
echo;
:: remove unsupported options in older versions
if %V% LSS 1703 echo %OPTIONS% | findstr /c:"/DiagnosticPrompt enable" >nul && set "OPTIONS=%OPTIONS:/DiagnosticPrompt enable=%"
if %V% LSS 1709 echo %OPTIONS% | findstr /c:"/Console" >nul && set "OPTIONS=%OPTIONS:/Console=%"

:: cleanup workfolders
(del /f /q products.* & rd /s/q %systemdrive%\$Windows.~WS %systemdrive%\$WINDOWS.~BT) 2>nul

:: download MCT and CAB / XML
set "@DL= function dl($u,$f){$w=new-object System.Net.WebClient; $w.Headers.Add('user-agent','ipad'); try{ $w.DownloadFile($u,$f)"
set "@DL= %@DL%} catch [System.Net.WebException] {write-host -non ';('; del $f -force -ea 0} finally{ $w.Dispose() } }"
if defined MCT echo;%MCT%
if not exist MediaCreationTool%V%.exe powershell -nop -c "%@DL%; dl $env:MCT 'MediaCreationTool%V%.exe'" 2>nul
if not exist MediaCreationTool%V%.exe %<%:96 " MediaCreationTool%V%.exe download failed "%>%
if defined XML echo;%XML%
if defined XML if not exist products%V%.xml powershell -nop -c "%@DL%; dl $env:XML 'products%V%.xml'" 2>nul
if defined XML if not exist products%V%.xml %<%:90 " products%V%.xml download failed "%>%
if defined XML if exist products%V%.xml copy /y products%V%.xml products.xml >nul 2>nul
if defined CAB echo;%CAB%
if defined CAB if not exist products%V%.cab powershell -nop -c "%@DL%; dl $env:CAB 'products%V%.cab'" 2>nul
if defined CAB if not exist products%V%.cab %<%:90 " products%V%.cab download failed "%>%
if exist products%V%.cab expand.exe -R products%V%.cab -F:* . >nul 2>nul
rem if exist products%V%.cab if not exist products.xml ren products%V%.cab products.xml
echo;
:: got products.xml and MCT?
if exist products.xml if exist MediaCreationTool%V%.exe ( %<%:9b "preparing products.xml for MCT . . ."%>% ) else (
 %<%:cf " ERROR "%>>% & %<%:0f " Check urls in browser | del MCT dir | unblock powershell | enable BITS serv "%>% &pause &exit/b)

:: configure XML nodes and file name
if %V% GTR 1511 (set "XP=MCT.Catalogs.Catalog.PublishedMedia") else set "XP=PublishedMedia"
set "XN='./products.xml'"

:: apply Catalog version for MCT compatibility
if defined CAB powershell -nop -c "[xml]$p=gc %XN% -enc UTF8; $p.MCT.Catalogs.Catalog.version='%C%'; $p.Save(%XN%)"
:: insert Catalog version nodes if products link was .xml, not .cab: 1507, 1511, 1703
set "@1= [xml]$r=New-Object System.Xml.XmlDocument; $d=$r.CreateXmlDeclaration('1.0','UTF-8',$null); $null=$r.AppendChild($d)"
set "@2= $tmp=$r; foreach($n in @('MCT','Catalogs','Catalog')){$e=$r.CreateElement($n); $null=$tmp.AppendChild($e); $tmp=$e;}"
set "@3= $h=$r.SelectNodes('/MCT/Catalogs/Catalog')[0]; $h.SetAttribute('version','%C%')"
set "@4= [xml]$p=gc %XN% -enc UTF8; $null=$h.AppendChild($r.ImportNode($p.PublishedMedia,$true)); $r.Save(%XN%)"
if not defined CAB if %V% GTR 1511 powershell -nop -c "%@1%; %@2%; %@3%; %@4%"

:: apply EULA url fix to prevent MCT timing out while downloading it - specially under naked Windows 7 host (likely TLS issue)
set "EULA=http://download.microsoft.com/download/C/0/3/C036B882-9F99-4BC9-A4B5-69370C4E17E9/EULA_MCTool_"
set "@1= foreach ($e in $p.%XP%.EULAS.EULA) {$e.URL='%EULA%'+$e.LanguageCode.ToUpper()+'_6.27.16.rtf'}"
if %V% GTR 1507 powershell -nop -c "[xml]$p=gc %XN% -enc UTF8; %@1%; $p.Save(%XN%)"
:: insert EULA nodes in xml that do not include them: 1507
set "@1= $t=[xml]('<EULAS><EULA><URL/><LanguageCode/></EULA></EULAS>'); $9=$r.AppendChild($p.ImportNode($t.EULAS,$true))"
set "@2= foreach ($e in $r.Languages.Language){$c=$p.ImportNode($t.EULAS.EULA,$true);$lang=$e.LanguageCode;$c.LanguageCode=$lang"
set "@3= $c.URL='%EULA%'+$lang.ToUpper()+'_6.27.16.rtf'; $null=$r.EULAS.AppendChild($c)}"
set "@4= $d=$r.EULAS.SelectNodes('EULA') |? {($_.URL -eq '') -or ($_.LanguageCode -eq 'default')} |%% {$r.EULAS.RemoveChild($_)}"
if not defined CAB if %V% EQU 1507 powershell -nop -c "[xml]$p=gc %XN% -enc UTF8; $r=$p.%XP%; %@1%;%@2%;%@3%;%@4%; $p.Save(%XN%)"

:: unhide combined business editions in xml that include them: 1709 - 20H2; unhide Education on 1507 - 1511; better edition label
set "@1= if ($e.Edition -eq 'Enterprise' -and $e.Architecture -ne 'ARM64')"
set "@1= %@1% {$e.Edition_Loc='Windows 10 vl Enterprise | Pro | Edu'; $e.IsRetailOnly='False'}"
if %V% EQU 1703 set "@1= if ($e.Edition -like '*Cloud*') {$e.IsRetailOnly='False'}"
if %V% LEQ 1511 set "@1= if ($e.Edition -like '*Education*') {$e.IsRetailOnly='False'}"
if %V% LEQ 1511 (set "CONSUMER=Home | Pro") else set "CONSUMER=Home | Pro | Edu"
set "@2= if ($e.Edition_Loc -eq '%%CLIENT%%') {$e.Edition_Loc='Windows 10 %CONSUMER%'}"
if %V% LEQ 1703 set "@2= %@2%; if ($e.Edition_Loc -eq '%%CLIENT_N%%') {$e.Edition_Loc='Windows 10 %CONSUMER% N'}"
set "@3= foreach ($e in $p.%XP%.Files.File) {%@1%; %@2%;}"
if %UNHIDE_BUSINESS%0 GEQ 1 powershell -nop -c "[xml]$p=gc %XN% -enc UTF8; %@3%; $p.Save(%XN%)"
:: insert individual business editions in xml that never included them: 1607, 1703
if %INSERT_BUSINESS%0 GEQ 1 call :insert_business >nul 2>nul

:: repack XML into CAB
makecab products.xml products.cab >nul

:: handle auto upgrade scenario without user intervention when script was renamed to "auto MediaCreationTool.bat"
set AUTO_OPTIONS=/Eula Accept /MigChoice Upgrade /Auto Upgrade /Action UpgradeNow
for /f %%/ in ("%~n0") do if /i %%/ NEQ auto (set AUTO=) else set AUTO=1
if defined AUTO echo %OPTIONS% | findstr /c:"Upgrade" >nul && set "OPTIONS=%OPTIONS% %AUTO_OPTIONS%"

:: import $OEM$ folder into generated media - for example $OEM$\$$\Setup\Scripts\setupcomplete.cmd gets executed once after setup
set "OEM=%~dp0$OEM$" & set "SOURCES=%SystemDrive%\$Windows.~WS\Sources\Windows\sources\"
set "@1= if (!($MCT)) {return}; if (!(Test-Path $env:OEM)) {return}"
set "@2= do {sleep 20; $r=gwmi -Class Win32_Process -Filter 'Name =''MediaCreationTool%V%.exe'''"
set "@3= } until (($r -eq $null) -or ((Test-Path ($env:SOURCES+'setupprep.exe')) -eq $true))"
set "@4= if (Test-Path ($env:SOURCES+'setupprep.exe')) {xcopy /CYBERHIQ $env:OEM ($env:SOURCES+'$OEM$')}; return"

:: finally launch MCT executable with local configuration and optional launch parameters
timeout /t 5 >nul
powershell -win 1 -nop -c "$MCT=start MediaCreationTool%V%.exe -args $env:OPTIONS -passthru; %@1%; %@2%; %@3%; %@4%" 2>nul
exit/b DONE!

:init script
@echo off & title %1 & color 9f & mode 120,30
:: self-echo top 2-18 lines of script
<"%~f0" (set/p \=&for /l %%/ in (1,1,18) do set \=& set/p \=& call echo;%%\%%)
:: lean xp+ color macros by AveYo:  %<%:af " hello "%>>%  &  %<%:cf " w\"or\"ld "%>%    for single \ / " use .%|%\  .%|%/  \"%|%\"
for /f "delims=:" %%\ in ('echo;prompt $h$s$h:^|cmd/d') do set "|=%%\" &set ">>=\..\c nul &set/p \=%%\%%\%%\%%\%%\%%\%%\<nul&popd"
set "<=pushd "%allusersprofile%"&2>nul findstr /c:\ /a" &set ">=%>>%&echo;" &set "|=%|:~0,1%" &set/p \=\<nul>"%allusersprofile%\c"
:: generate a latest_MCT_script.url file for manual update - could have made the script to update itself, but decided against it
for %%s in (latest_MCT_script.url) do if not exist %%s (echo;[InternetShortcut]&echo;URL=https://git.io/MediaCreationTool.bat)>%%s
:: use MCT workfolder
pushd "%~dp0" & mkdir MCT >nul 2>nul & pushd MCT
:: (un)define main variables
set XML=& set CAB=& set MCT_VERSION=& set OPTIONS=/Selfhost
exit/b

:choices dialog with buttons: 1=outvar 2="choices" 3=selected [optional] 4="caption" 5=textsize 6=backcolor 7=textcolor 8=minsize
set "snippet=iex(([io.file]::ReadAllText('%~f0')-split':PS_CHOICE\:.*')[1]); Choices %*"
(for /f "usebackq" %%s in (`powershell -nop -c "%snippet:"='%"`) do set "%~1=%%s") &exit/b :PS_CHOICE:
function Choices($outputvar,$choices,$sel=1,$caption='Choose',[byte]$sz=12,$bc='MidnightBlue',$fc='Snow',[string]$min='300') {
 [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $f=New-Object System.Windows.Forms.Form;
 $bt=@(); $i=1; $global:rez=''; $ch=($choices+',Cancel').split(','); $ch | foreach { $b=New-Object System.Windows.Forms.Button;
 $b.Name=$i; $b.Text=$_; $b.Font='Tahoma,'+$sz; $b.Margin='0,0,9,9'; $b.Location='9,'+($sz*3*$i-$sz); $b.MinimumSize=$min+',18';
 $b.AutoSize=1;$b.cursor='Hand';$b.FlatStyle=0;$b.add_Click({$global:rez=$this.Name;$f.Close()});$f.Controls.Add($b);$bt+=$b;$i++}
 $f.Text=$caption; $f.BackColor=$bc; $f.ForeColor=$fc; $f.StartPosition=4; $f.AutoSize=1; $f.AutoSizeMode=0; $f.MaximizeBox=0;
 $f.AcceptButton=$bt[$sel-1]; $f.CancelButton=$bt[-1]; $f.Add_Shown({$f.Activate();$bt[$sel-1].focus()}); $null=$f.ShowDialog();
 if($global:rez -ne $ch.length){ return $global:rez }else{ return $null } }  :PS_CHOICE:
:: Let's Make Console Scripts Friendlier Initiative by AveYo - MIT License -     call :choices rez "one, 2 two, three" 3 'Usage'

:: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: ::
:: For completeness, insert VL entries for products.xml that never included them: 1607, 1703
:: I've chosen to generate them on-the-fly instead of linking to unnoficial edited and third-party hosted products.xml
:: $csv holds condensed official hashes and sizes for 1607 and 1703 VL esd's, later turned into full official urls needed by MCT
:insert_business
if %V% LSS 1607 (exit/b) else if %V% GTR 1703 (exit/b)
if %V% EQU 1607 set "params= $release='RS1'; $build='14393'; $date='/2017/01/'; $code='.0.161119-1705.rs1_refresh';"
if %V% EQU 1703 set "params= $release='RS2'; $build='15063'; $date='/2017/07/'; $code='.0.170710-1358.rs2_release_svc_refresh';"
powershell -nop -c "%params%; $f=[io.file]::ReadAllText('%~f0') -split ':ps_insertxml\:.*'; iex ($f[1]);" &exit/b :ps_insertxml:
$csv=ConvertFrom-CSV -Input @"
Edition,Arch,Lang,RS1dir,RS1sha1,RS1size,RS2dir,RS2sha1,RS2size
e,x64,ar-sa,d:672bb229c831b84e95a6dbff94818528894540d3,2955820350,d;8efb029378cd955809e67baf2cc71c53c632e32c,3269761758,
e,x64,bg-bg,d:97d613cdfb2ded4df2f71ef29fc93ca3656c6ed8,2911551848,d;64316f68725e92c2567dcf86981e5eb1c635fd09,3221290404,
e,x64,cs-cz,d:7542eab92328937b8d09ee02cf8fa9cc6a196830,2918785956,c;5d0fa9367cbc1ce83ceb9ec130af97000e89b150,3231413240,
e,x64,da-dk,c:bb9da04cd47d7973597386ffd203ed56e19d4d65,2946222420,c;3005a5859d2010da9fd1a77e6aab14ca233d73dd,3248303690,
e,x64,de-de,d:c9b01f8eceb84ea2e7abf8c8823a623d759a61d0,3019388686,c;f813662c59c2a382a940d82b96e825de80da7089,3348816134,
e,x64,el-gr,d:14e182c6ed9ba36c720fbd0c3f5ce7d64ed38ca5,2933879638,c;f2f713a69c342e4b6513bdb8974213530f37d6ee,3245990678,
e,x64,en-gb,d:b972022ec65c9205195833b842983e527f287d0a,3002224046,c;a7100680c5718d34474579b0154819e2e528ffd7,3312981002,
e,x64,en-us,c:cbf97f9ee545d6bbff70c7fb9740e9fe5d6f4d77,3012544034,d;5477ecbdb80b477d3cb049d0d64831b72797be8b,3312849564,
e,x64,es-es,c:d6b21213c81c83c46965baf0c1da2f14d4f3eff2,3002625924,c;cf78240f01de56403f3ab7066cf061178a90ef3f,3319718002,
e,x64,es-mx,c:e7bb91c6aa0c9295718f0ea2761005ac4c556cc8,2943527594,d;8b4f2f3b2bf76a6ee78339332bb18e0476669b4d,3273904408,
e,x64,et-ee,c:ca9eba2953c9aed39e051f5d984e4a58c945d17d,2889988048,c;2be6d35081b25a3e808343ea0aae69fbe781f506,3200923112,
e,x64,fi-fi,d:b250bb11cbbea356417993455d639582ca4fd052,2932564162,c;5bde9ca7461591e51af74416335694ecc4b1ca5f,3230886556,
e,x64,fr-ca,d:e33bc497cc5ef1a2ef362c23d2814d580aa22e26,2970085652,d;cccbccd532887d278fa922fd09f56bfdca5088bb,3294268308,
e,x64,fr-fr,d:b599b3275302e57b8e1ad25271da68c299c4de39,2996998394,d;64ff0e97c469fdd3b591ae226a16ebaa75c7e8d1,3309828430,
e,x64,he-il,c:b82d6122d55c838393c5645520692acd101834a9,2927278142,c;d85a04e8c72279d00889be97fa9aa79e88964a89,3232690912,
e,x64,hr-hr,c:bc2cbd1d92e60598115098238f12e8dac2c2166f,2898184950,c;b07812c974941b314884778654da1831f41d838e,3212042850,
e,x64,hu-hu,c:a0453e7dc3d34716caac2cacb473aa65ccecea3e,2918877960,c;3eec65d51e8c24e8b0c823071ef246df465270c9,3222250300,
e,x64,it-it,c:9b48a0fef984b867e8018708785a6c70a696a469,2953574274,c;12c773f8db4c66d1a7d039e689a53e711f55b23b,3272240844,
e,x64,ja-jp,c:ec30e2dfa29223fbeda28feeed89f7ed6d2911fd,3063387292,c;e214f6797b2f174db15901b79ae0285a0859e5e5,3391347078,
e,x64,ko-kr,c:8b9af5c684e639b1787c901baddb33e3ec1f17d5,2979348462,c;801a09ef5a8b28a98b620bdb83472f2a17265e17,3287839184,
e,x64,lt-lt,c:97f81a28fa526e57e2e38235ce7103aa0fca0ff5,2890387644,c;11584883f422bbd13394a3b7aa502572bf204ba7,3204395822,
e,x64,lv-lv,d:26775e677727ad2296e7de0620be132d144abd55,2897092188,c;c29e06c7e338df384fa4d0ec1798b07b4175056c,3202719722,
e,x64,nb-no,d:7c42bfed895f37cf86153ee75325b5d4b71e3eab,2922664364,d;9b80ea391601f5eaa2dc82a86b51e4e8a5ef00d6,3224730246,
e,x64,nl-nl,c:81b8974317b76417ae102951ec191f90fdfc00f9,2934556272,c;9d79d2877e7015039b7795311ee33b12e82103d4,3233989634,
e,x64,pl-pl,c:7ddc4be2c46d3aa5b562bc593936b7bac33c6a4a,2929138222,c;78b3c876618557bccee0e9437466d70c0c136dcf,3254871838,
e,x64,pt-br,d:71de2e5a288324151bec24830bcedca5ad77a1ad,2953378710,d;01c57b64de3a66b7795c363ce0b80ca3567bcb49,3271500426,
e,x64,pt-pt,d:52dc57e4107dec547e68a9e74eec10244cea4f92,2941611330,d;6fdb16fb6bfd01cc846818eac4bbd468731137d3,3240619572,
e,x64,ro-ro,c:24950dd0d69cd50fe01f8e9309583772ef231518,2887834662,c;3b61d2d6592bf7172b20b6c087465e4e201a1b12,3213373488,
e,x64,ru-ru,c:8ce69e0236a2b5269c08a67edab908211585b3c1,2957770620,d;702da7305af22183af857b1d92f225ba89c846b1,3276687624,
e,x64,sk-sk,d:14accd88aa808e900ba902ac6509a5786d41be79,2888894912,c;2a76f3cf95bb8816bf2a4a77f60e5500eb0260df,3209901276,
e,x64,sl-si,d:c1ac7d37d86e4dbdbb2992acc8d3b6e60e52919a,2881745984,c;45c67e340e223378aa8aa6aa5678d1ac5e3285a1,3205356168,
e,x64,sr-rs,c:f8d80cb91733aa8b48c6b84327494e210b8e5494,2910809030,c;59d39830461b47692ecb8d8b3d3d5b5510bd2b41,3211056238,
e,x64,sv-se,c:d6196f5e660ef7055a0a5efad8892045131a7f9b,2931748080,c;d5bd28ea94a57f48c5dd9be95eaa77e1af5b879b,3225016350,
e,x64,th-th,c:1286f4fef88b41884d8083aad666d63ca232be42,2910791934,d;10e7d1628d17f175c7be22b9cbfc31b0f4d6cf11,3225739176,
e,x64,tr-tr,d:871cf4807375a39b335468d44407023f19bade5f,2915633822,c;2bf79ce9f82e719816523039c6219fcb1681f211,3223779720,
e,x64,uk-ua,c:5b88fcd4211676ced3350a9bdf5abe0a37707991,2915857130,d;4689166d55d8b658144c219da32025ace59071be,3231204960,
e,x64,zh-cn,d:e78e04e6204b107ffa36d898d58232c86e98199d,3131493920,c;ff6a432a6ee8204153cc057074fb07b5a41f201b,3475307584,
e,x64,zh-tw,d:4b4e82301a37192b69d70496fcf57c16aad681eb,3059396808,c;4b15f3fa006b472788efda8daae41dcc1cdc6335,3402457552,
e,x86,ar-sa,d:c6daaa38f3eb589e8654a266320032ed3aa3a6f5,2253811598,d;489191d8cc329b9721ff26287bc71ff4cf02115a,2494711944,
e,x86,bg-bg,d:2c0063b9f769ba2307f84717ac2b915206a9d4a3,2218360574,d;117a347347deaa73dce186af781b7eda8e4fc62f,2450825804,
e,x86,cs-cz,d:3108854bb25b7c75bac13289db5c2a2e9c920578,2214354874,c;30aa6d6caee1e882fd88018c7ddb9a747499b891,2450581096,
e,x86,da-dk,c:297f5fb65fa79f3ed1d0a6dcad202d863b71e9bc,2240352350,c;5451990e566561a587a8fd44bf81f3236fb27a8b,2469352822,
e,x86,de-de,d:8af78913db117260a888d57c5376470cfc109670,2321843034,c;a19f69452edb66da0591a63ae7a2f9b319bedad3,2577096876,
e,x86,el-gr,d:b8bad577e15fbfaa27b8bdb53d1c6724fe64357a,2226440968,c;da04cef145557e500060759c3b759c03adf0580c,2468826000,
e,x86,en-gb,d:6d0466628b39e192bd675fae1dfafded7fff94d9,2305860070,c;c4371bd42a1d3463c40ad05b4f328471e8be80c4,2541092494,
e,x86,en-us,c:72e16690f022fde1c59abc93457a1c6b8bd4c5dc,2310343386,d;65162f45583f38d53d01c5e5a64a69d1e73cc005,2542115274,
e,x86,es-es,c:4b3999d40e9ac39c1ba4c1dec301c51aacc50f28,2298493682,c;000f7839c99dfc3e883c9c41a2e7e1f9b9d1049c,2547575630,
e,x86,es-mx,c:3341b800403bb93375745ea4c3a4529ae5472fe3,2249633892,d;9315c4f7cdbacac86b47aa2637e90b1820c1e0b5,2496325838,
e,x86,et-ee,c:06e7a360daba3388edefbdf56d958e98b2cae2d2,2192782608,c;1bb3b0c7df189c3cf2504a6c7b3044592991f510,2429782490,
e,x86,fi-fi,d:3d13bc3b7ca9411cd791c5c861e022bfbf2db2ce,2235053854,c;32a72a1c0d4e70f7940e91c3e60aa10b6326d618,2455546618,
e,x86,fr-ca,d:2200c921718cf3b8246cf4e82ae7127668790444,2267316492,d;904abb865818ee7ef3259129f49fde9464efd4cd,2520878858,
e,x86,fr-fr,d:8b6805f55fd7c6641d182131f500c0340887c0b6,2297031996,d;b2d1ccaca7117637ccc74c86876d6289ec2499a3,2542088822,
e,x86,he-il,c:4011de9ecdf53b41fdb2ea9e0910bc6a0bca7939,2224939840,c;8a6662b13ceb703d8ccc874351843fd6f9918ee1,2455101288,
e,x86,hr-hr,c:c689528beb00b9157cc3d08c2409ffaec84ea56c,2202588894,c;22b5565943863d9a82f6f0af17d0d8796e40dca9,2433083014,
e,x86,hu-hu,c:47e181c321033ac99850fb222047635a83d71d43,2223268852,c;b50222d340eb136fd736f2eb256c97072ed74f14,2443754316,
e,x86,it-it,c:4e68dba7258c1af508d8c180564749b5b1b9b3fc,2247219130,c;1833f47a8968d2b31a8c90672dfb76d57a5ab022,2500145118,
e,x86,ja-jp,c:24d900e9937c520b10056e53775e6a5934a916a2,2355095860,c;e7c95f7ecfc9a46f1a66479ead6c6fa6194c0e28,2622699920,
e,x86,ko-kr,c:296956b802ccf9a76083e6398db20d2b67186fd0,2265728512,c;a7e52b0652ad20c351d8d5a79cc4e7904f48390a,2511245616,
e,x86,lt-lt,c:1636c7532f21ebf6282e785f35840201ed6cb81c,2196863664,c;14be449da61677562b2f49de9f401a84d6d2c88b,2429457908,
e,x86,lv-lv,d:aa16e2b2f317ab45e43885bb700a428d74244ef3,2196617270,c;1b85049cb4f85c0a50723a17f2b566c3ae05aa9f,2429484246,
e,x86,nb-no,d:a9bbff5197b258a37d4639a9699e938f86030777,2218857478,d;dfd2952d9ee50ffdaf70729577655fb52bbded02,2447487494,
e,x86,nl-nl,c:c1ad0d57e0ba595e81ef7820f9db2b7c12114629,2223733356,c;db4d9998e2891a2c11af49e8edf864c4d669bee8,2453608998,
e,x86,pl-pl,c:165494554c7fdb1be55e4399b6372515c2d6b1ab,2228062654,c;be5d2f555cdde8925c1ebd08a7f7a3222c9e612e,2474897208,
e,x86,pt-br,d:a5006f26410655f0efa3a42c0ff63b6c9acf4d74,2264016962,d;ffde6034bdc95b6b3d4e651a8677ddc6bb2d180c,2503336302,
e,x86,pt-pt,d:0b1a60b57e687aba766001a8b306870c9e7241b3,2229207498,d;4d41383f7e149f8f332683a803e80913bc9b1dc2,2472391446,
e,x86,ro-ro,c:f1d43e2cbf3006e034b64eca9bc94de7ffa8cf94,2201439796,c;d150722d68fe7eeab6584e6b91ce40a51f6e83b9,2434175900,
e,x86,ru-ru,c:50f2f76e8a0e62f26a6238fd9471b16ca1b26186,2261034630,d;e4925023ca2a7c875a257542177f51adef9ac00a,2500599630,
e,x86,sk-sk,d:1796ddb7072d64e971b3f7ef7c3c3ecadfc7dd00,2197855320,c;2062f6e7a1cb1ae6dcc8755b6afec3cf92aaaeba,2428270146,
e,x86,sl-si,d:2bcc0dd24a8fcf85e041d29c27be612d20f6c39a,2196163006,c;5edf9bc85d7893d5f8489693be58606ffd0733ce,2430123934,
e,x86,sr-rs,c:242810176bd2c17e25c94b5478762bacd04f0c2c,2204793922,c;905b282702bd35a24335e13b7532bebdd6500577,2432563554,
e,x86,sv-se,c:14642e83ecd3d000bfc10d5bcea08de83ca1fe39,2231055130,c;fdec6fe68064a5863424adbb88b1f3fab2f8f9ab,2456236258,
e,x86,th-th,c:5660b3c566e05bbb58504c392470916996988bf5,2218450936,d;7e6804bb22e995c8d7fda7bf17003f1a598923c5,2452122006,
e,x86,tr-tr,d:2dbe29adf9297d98e66e42558fa673c0e76b4cf8,2215962556,c;440ca442a89e088530739ad7b1fb911aa4455a06,2446042716,
e,x86,uk-ua,c:02a14a526045c75cbbc1aa279d01f1f23686dd93,2219357380,d;e45c9e3569ab5763f1aa8fb3363256278a665d19,2453614364,
e,x86,zh-cn,d:2ddd95d076810d788d63082cffcbbd75bf921243,2421427008,c;feaf7891cc55c6f2716923a5e5aad8c9edccbba3,2693601882,
e,x86,zh-tw,d:589eb269e0666134c1d31d67c665da50ea9b2a66,2361521848,c;ee8a66c1d34e68ba480b017f9aeed538a7847b05,2621863118,
eN,x64,bg-bg,c:d090ecc0e32e05a6c075eb8384f577315ac35ee2,2773448902,c;859fd1064516d2d86970313e20682c3f2da3b0f7,3063703618,
eN,x64,cs-cz,d:3979b107d1af43aae3cc79bd7a2a081def5d04cf,2775734726,d;5885cef1a0a88972eafbf3240a91944a5bbaef0c,3063480034,
eN,x64,da-dk,d:f0a667d9584f10c47b3db96b0e6700f1a47021c3,2799132592,c;049db05e06fc85f2e4fa47daf620a91219f94da7,3064590226,
eN,x64,de-de,d:e8a1023f0f21a7c99d1b5006ef520323238833cd,2888504080,c;8114e5eade5115f06e87cc63d82a56e6da4e9d71,3175541170,
eN,x64,el-gr,d:8bd00622321661b9ca1eb7289d907a9056c713ce,2798418934,c;b02813b4225d89cb685c75b0d13950e9f5af90db,3068824274,
eN,x64,en-gb,d:f145a8eff3121dc8fb020c5a1750a0f2c117ecb3,2861883002,c;10b79168087eedc6f574af4c6c6893313702ec85,3137564572,
eN,x64,en-us,c:fab646ab44b5d956a91e0d2aa0e4a37f22ddf7cd,2859877184,c;3e2111b94ad40b063d6fc224da72f83205c374c8,3140230812,
eN,x64,es-es,d:7386e7b352e080a15f6a565feeace4c6e854703d,2848523494,c;9bbfcdebcd28939d5463630e0938ba6a82c69387,3147765694,
eN,x64,et-ee,d:b487809fa9f137624e4bb205e389f0e599d17093,2748248864,c;577a6202ef0105c44fa46e852f02cadeb4d8d9a3,3032725650,
eN,x64,fi-fi,c:dc40703bd5eca75ce2d234e367f23db5a71c807f,2796624854,d;d9c35e5ba0889424e10bd1391f482270b3c40853,3059882946,
eN,x64,fr-fr,c:5838ee4f277ebd8ab33f3d40bbcc380a95f9e69b,2852055774,d;34e9d32c32d40b6fa1bffb9d5e43b7ee52ccc8a4,3130815842,
eN,x64,hr-hr,c:f8d5c52045248839329634468038b184b7e9a491,2765426784,d;80fc1b08c6b4d89b65ab5d4aff5b8c4460120800,3033535336,
eN,x64,hu-hu,d:65b67804be6e6a5e66f0046a8c779fc9599b571e,2780468248,c;ff090817737eabc45aab729654e73446c79b053b,3056933946,
eN,x64,it-it,d:162bbba0399ed2e0cc12569676f4afcc685f08a0,2798572882,c;9f8316c823d069842e8cc52d9ced8b6915bfd612,3100499922,
eN,x64,lt-lt,d:11c047008667638f72cfa7391b0ac14ce954a427,2755834506,c;9aef261cd6fffa9d1db2ab1ab7cd52678ef06094,3025353026,
eN,x64,lv-lv,d:230ac84bf1c669d375fd05159a8d26edb87cf264,2752316336,c;7fa4685a86839f3d8093be889e7dcb14b99a4581,3029332916,
eN,x64,nb-no,c:7939fcefabeed9a8cebf6ca04984e9c0f8470f50,2773039326,c;17ec8c4db6dd115fc45050205d4ee391d55847a8,3058404996,
eN,x64,nl-nl,c:fbb84419e1b8618b83b91873ed5cc7fa1365a009,2775118184,c;9af5d931ed90868395e94fa99e15ce723153e7b4,3058285820,
eN,x64,pl-pl,d:7ea026557e632da890a64e0fcf72f3672ef12e53,2778912686,c;3b8c6e1273d2d65562b81b0b1b63a8ce9ecdb3aa,3082538930,
eN,x64,pt-pt,d:0afce496d59bbfc1f1c6580dfb49bf0ca1e30275,2787935254,c;763b5bb74b702c18ba80f770dfa25a7af4dc4f91,3074473316,
eN,x64,ro-ro,d:d88e0b470995cc081f9e73d06baf0ce6080445c9,2763055438,c;d9883e4a8242398402383ae47e4015a8c724b2f7,3035031152,
eN,x64,sk-sk,c:be661b5d237a8a93259d64754b09ae29f26cb42b,2763328164,c;c705871aa637455dbf04532b5ca462539d466d6d,3036114496,
eN,x64,sl-si,c:73a4a166b1eedff7c7465eed4ce3daa8eec1c051,2754008752,c;cb1485805fa62f1ed18d28a0418e45c5d612b31a,3026544424,
eN,x64,sv-se,d:70e0831a0c4078705b6699e8662d6cb0dc4875a0,2799778090,c;6cb6b740c9f5390f0e1bd29cd33890a78f20775e,3061594264,
eN,x86,bg-bg,c:f2206f926561fd89b69d6e7e61aa98956966dfd6,2111500580,c;3f2d95b5af40290989b42d7e85fb73c2deecb107,2343397300,
eN,x86,cs-cz,d:e773288e71f7a17ec8e1525415134acbfa13a803,2113434488,d;ebb7e9db690c146503c1470f6431ebb3b9f90b8d,2339478712,
eN,x86,da-dk,d:9defa59a1627b3440684ce9605a43a0c4e88c770,2137434148,c;bc154a20faed8cb135617ea5f7c804a78b041663,2359187156,
eN,x86,de-de,d:e62e766faffcd25ebce37b758aeac6e63208c332,2219030252,c;829e8e3a44ee0793a6c10b76d6fc0180cca52c60,2469646676,
eN,x86,el-gr,d:880756cb261c7a7b32289e549011d9bb968d2706,2123659240,c;1731ca121d36bb3115282277de3f467dee4eee2b,2359266864,
eN,x86,en-gb,d:7c3415af341630a1f01f2f0983e44579d6a23487,2200050658,c;d45cfdcc6d7227a8ed12ad24d718df17709fa8fb,2426801288,
eN,x86,en-us,c:5166cb73561f9c1190f9d6f8a35fe444877318f9,2201813278,c;b17b8827e6954672d2bd85276b73770801a3bf6a,2433137092,
eN,x86,es-es,d:191a58383195e53864fcacb41313043a5ea77663,2196489320,c;87974fab21f2e4ffc783ee6de4e6942a6bcb943e,2438326380,
eN,x86,et-ee,d:d9f88ee10c3f41e5e152b24c78a35ab1f15d6af4,2095947306,c;4e55f61f68aaa863f3e98bd1159d09fe90508a7c,2320212652,
eN,x86,fi-fi,c:d3ed9db8b398eda4497c6b9d897555f5a5663d84,2137783028,d;70e4f643e220a70547bc75cafd358e5c247a918d,2342513800,
eN,x86,fr-fr,c:36286ca54f121ca1247e1026e0c76bf3fdc4f2be,2193600366,d;61eaf46743223466e066c77c0563ad46501378d5,2428304540,
eN,x86,hr-hr,c:742c2541073a78be847cbe684651b7fcab6b6fdb,2100724714,d;ad15cd4f66559bdbe0c42552f4d9ff645fcc5151,2328147230,
eN,x86,hu-hu,d:444ac3b15980f3ef4f911fa2f920891e230118ca,2122154560,c;5bdb5d7c487fc0fb37b8b76c66c1f3e8e2682f06,2340664250,
eN,x86,it-it,d:f4deb16739ba26ec597725cc5a9a2580b33e7ca2,2144445692,c;4089301a2ea267526b974aae278aa5e0fc0134ae,2384586126,
eN,x86,lt-lt,d:0a1d7d1bd8456251c623d5c3f3e7e6f0a9c00e86,2094863630,c;d1725c85939679dd82fb8d551909e8686773e53f,2325646266,
eN,x86,lv-lv,d:98948912070a686f3b7060b9f80446faba677b2d,2093716546,c;cdf68b52a97795d3bbddb17e08f5153868423082,2325624994,
eN,x86,nb-no,c:ba8c7be3fb2a12ae3a227ac60b69ce225f367933,2113695528,c;ab6a56a1e544b30cda33601f60ffdfe4b7a7c010,2337861734,
eN,x86,nl-nl,c:40d9d1a599a5266947f337fa6acfcaeeece8a865,2130921230,c;202eed2dd65dab2791ec1a4b04afbb1a28ca997a,2340806626,
eN,x86,pl-pl,d:487eab83f1e6f67058b50b9a889d790f49384567,2125591884,c;5292273b4477d413dcec2533ad2459ba1821891b,2365075840,
eN,x86,pt-pt,d:40a28c0263920c0e13a1c450511718f61f2c67e1,2125017148,c;5659133bec9806a48096068ee53c2838beae6f6c,2356933976,
eN,x86,ro-ro,d:5452de2544692ba234c744cb18676f1cbc3c7c3c,2101442992,c;efa8623d089f7df5c41453b862c9e686d0b0b157,2329162166,
eN,x86,sk-sk,c:6322ebdfaea5955e28ec0edba5595e6ecc3eabba,2096292986,c;b9b1705f81a7120a2bad78ffda154182814d53e9,2330022126,
eN,x86,sl-si,c:882e91a3c1e7a239ac4d39288c19228b8ba20c8d,2096786702,c;8cccac3b248a6e6879bb8f5baeb06a375bc8fe68,2326113308,
eN,x86,sv-se,d:66c58033888d81d9e914463d941a525ef1f1c29b,2130127248,c;2e1c69c5a253cd7b7ed381e8a7d9ff02350ca8f2,2339127740,
p,x64,ar-sa,d;763f8d3532a4c3d95dddc0239ec6999c6c063c43,3017152712,c;3963c262ac8d2b8054df782a94354ffbd234f52d,3269139960,
p,x64,bg-bg,c;c56a9b9f6e7c37fc548686835755676ea04625d8,2968435508,c;d9868eb90a2d6a89244a402adfcb3fefc5a2e0e0,3229523040,
p,x64,cs-cz,d;4ac0dbd8eb31b90ea7b500083a1a71f9665fb677,2976799184,d;b2c8da4d2f96e81a1dfa20a38e318ef604d27587,3225207160,
p,x64,da-dk,d;a15c3a85061a12b7cc9b366157bb9fbc30d71aba,3009307712,d;8bf3e4027b0ee612a32bfb0821e9f4424030c71c,3242370264,
p,x64,de-de,c;dea2c577e64546463080a96c4b075e924a60d412,3219035316,c;3f35923a27d57e6b531a926824d68d70ca201e23,3349142306,
p,x64,el-gr,c;4f9089bfd9b0815116fce8ee104a07f445ab82e3,2991041138,c;fc990c37e360b0b3242ae7b4989fd3bcc457635b,3246934952,
p,x64,en-gb,c;db057a5eac7cb0d65691e758f3949c13f26a513d,3176583254,d;7e7b2b9d0c229a5083fd45a7d17e77bcdabf8e69,3312166688,
p,x64,en-us,c;a67fdee4fc4b5703b4ab599a5578a2dbe2f655f2,3319805853,d;4ec0294c4ece0c7d977c7de1fac74f5a43412c37,3306899294,
p,x64,es-es,d;8428460416a1effb60b2e204c40c436cef439727,3089825090,c;d62f6693f86651315289ec6c2a36951e330053a4,3318862104,
p,x64,es-mx,d;0d6d30912e3cfb6b05481a8dac29cb165d5ec531,3021626512,c;5732b1f2c9716012a0a5e8262f380a903b857612,3266281600,
p,x64,et-ee,c;736038bc59a7adbd86622480076d54c916ca583e,2947223572,c;4d4653f610d9ac20bd32aa4860a055c8ee4724d7,3199845540,
p,x64,fi-fi,d;894658288a4de3bdadc3c92caafbc77d6beaf8df,2988097106,d;a9ce6b78c9dfd83bea9a93f9693dca3db27ea3f0,3224291788,
p,x64,fr-ca,c;b7af8f72ebeb77a7529a91ba82fa96b5d7c1aca5,3057151984,d;48d917594ec3ee11df4ecb89a28d67d5621d34b1,3288230206,
p,x64,fr-fr,c;fba5faa2d2d3c656a6e2180be4aed091e179dfbf,3151088370,c;fcdef8db06ed83cefc4a9764edf9e300c8a834e0,3306810834,
p,x64,he-il,d;cce395f6f1ef65da5a9514312f7988fb975c7aab,2988102890,d;352cb000c67fdb818f2b6055354a167d4cd0a69d,3232992066,
p,x64,hr-hr,c;c6a879a1bde4828296073b45bee522a530fde1ce,2964453442,d;f939dc75371ec69876c572d491498aaa4a0bea72,3211331764,
p,x64,hu-hu,d;952368f507a15afac4d0c4c42697c36794c57a28,2976155974,d;ab6424a97b162cc189a3ee111f230b9b5decefc0,3221998158,
p,x64,it-it,c;ac52981de1ff7d7f7b8e8d2a4981130dd9b7062a,3027424610,d;b14fbaaa8ac55b6036fa2749bdb10d9eddfca97a,3271830856,
p,x64,ja-jp,c;87dc289be935d27958cf49f9d97b3db6f2d69721,3249832189,c;4cc008c93ceb0b76392a1c012c76ee14fcbee660,3399536718,
p,x64,ko-kr,d;9f5180fb3d8792b87ee078df3b64cc1504221b0b,3053846230,c;b6399dbba1a2852805086b4581d4b202dabd0d2f,3286198386,
p,x64,lt-lt,c;cd7650dac53a9f94e1556879d30ed5965a0703eb,2959202730,c;8a7beb73b01dd32141ad119a09a8bc01ebec01da,3205686580,
p,x64,lv-lv,c;060160161b5ed79d53a3bffa7fc0014806664979,2967916812,d;26425a6a8d0f6aa9a05782977b692e190f7b3fe1,3203530768,
p,x64,nb-no,c;80dcd802fde6998d7f82d9e34457d29106180150,2986394866,d;cf80da8119dff6edd83fc14d04f1c07a93154522,3227302824,
p,x64,nl-nl,c;64a639f0066eed9c454e3e33451efde18dd6ba98,3005059082,c;dbce7a99d33758f6880e3e25869f4dcf8cba168f,3231406962,
p,x64,pl-pl,d;953d0e942518a30e8e98fd1dea151926fc8944af,2988628234,d;711e0bd9cba640f046d24c965478dc4c64b6bb56,3254396898,
p,x64,pt-br,c;9d925ec3a182e0c2822e37900f89bccb79c666ed,3030217044,c;6a1729c45317670a371ab95a2888c8d46c246efd,3271791946,
p,x64,pt-pt,d;5cd6a59fe21427feee2a34f825f8783752c23d5d,3007507556,d;543d6cf7ba085eb01fe476589b3f853f68e14a1f,3242820652,
p,x64,ro-ro,d;b15bf61a558013f5202cd175308979af0a95d49a,2955444630,d;7043ae390b72561e8575213280c65932fcd57bf8,3212920292,
p,x64,ru-ru,d;f27830fe80f8a1f56c1d492d1007f63363ff69f5,3039587116,c;5c82a5b3d47e369e08950d1bf990d66af71382ee,3277964848,
p,x64,sk-sk,c;ea535aa8e2d891fdbedd9cd6a7d261c91280e495,2944655478,d;2be1c1c86924229c575ea86256ea6ceafa9250c5,3209614406,
p,x64,sl-si,d;50c210f92a64a625d320fbe704d1e2d0fe129dd1,2941825400,c;a76a6a9aba283de1d5a2c13e25f2d6f46b7b7328,3193801558,
p,x64,sr-rs,c;235a4d11b0346a527f34e68822b0d08af5637323,2972572460,c;35e53089ec427c155f267988176a98a9ba6729c1,3205347802,
p,x64,sv-se,d;956f1c12d67edd9ca19cf26a9b871610c4e51758,2996962528,d;73a9dc803eadeb9026e7e431cb244af6bfe7c0b4,3238580990,
p,x64,th-th,d;64529e2290a400a605093bbf7169060ac0f9bbbb,2976849192,d;edc54e4750f7716be213f9b18e65b4eb492be1f0,3233561098,
p,x64,tr-tr,d;65612b0b4ac01f1bb2fec7b8a161ff31b9bf7ebe,2975807725,d;f800b571c0045b463801a504a7025816ff741d6c,3218876806,
p,x64,uk-ua,c;3d2b3939b2f60afec719c89443b170c48fba83ac,2981529906,c;867689f02d837ec57b73cd705ad7bf8c70c7ddd5,3230917596,
p,x64,zh-cn,c;efdd42f9baea736aebfb443922ffbd0de4b0e2b7,3203380142,c;63be8d0a2fb3ede0f5336ab238c871a10a2a3515,3462073854,
p,x64,zh-tw,d;ec6068642e34a049a9bf9ff79ea439722fe6bfec,3136948712,c;450f612a2ef4eb388806e0e71456a45f3ff86702,3405611514,
p,x86,ar-sa,d;1bd076aea51f88e19c600d34d06050f78e87099e,2316041282,c;9576073ffabf77db7d51f90a37aa2df01f3fabd0,2494401210,
p,x86,bg-bg,c;d9ff9494d106af25bad566591933e20f3cbb9c01,2285063890,c;dba3940d5ad6dc45140bb6994d20aa527766cea6,2450825844,
p,x86,cs-cz,d;f721cf9c925e778ab8b0014cd8727156613664a0,2275903108,d;50c30eb573ec91cfcca178745775d38f7b986b78,2450450424,
p,x86,da-dk,d;e830209b7541756470aa21ebca191dfc6ac39561,2305464234,c;c9a3e82cf520a3814454c24c35a4c06919ed1652,2468847300,
p,x86,de-de,c;968aaf9107ec3d486f1125a109a1ade30cae07db,2495166956,c;4e203ac80f25a6a21727dc915d80074bc5877954,2569095198,
p,x86,el-gr,c;6e029e44b04367c7f684888280b52666f999b47c,2286941358,c;dd90f8a993016a0847101c8e2eb1b059177860ea,2468868678,
p,x86,en-gb,c;21fb6904b75427ffc9e9d3fadd3e0df9a4035598,2476842804,d;b611bd4eb7e100596062445444a90b37d32a1540,2540699908,
p,x86,en-us,c;d91e124cbe2bfbd372a936a401bd462f4773ceee,2602533592,d;5af2b28a2edeee03d47c17668797c8795cf56d2e,2541865106,
p,x86,es-es,d;b5af8299317ac3398e93a122b06c846c4e18b6a5,2370591066,c;7ee3ab0dc272ae71ad9638e64f734bc733e20a51,2546579330,
p,x86,es-mx,d;205d7918b164275b9fc747dd05d9bf3d5d82272c,2339980484,c;ed1de56ac8f100eb7ceed68da3787004434d0c6d,2495688050,
p,x86,et-ee,c;e39b8aebf84482322316e54a8e7fc03b200d6b5e,2250794742,c;c067ab95f0417dfe757f673f48cf77606ced0e99,2429532836,
p,x86,fi-fi,d;5a5a127d2b9f67eb076b2bb8a8d05588ab33e41c,2294397954,d;5145376a20a27f09b990b8442c062f91139f4b59,2455923358,
p,x86,fr-ca,c;3921cf2651b9bf40729c503f59ea39dadd67c1ca,2340335032,d;0d84ca5ed316ab3dddc76ecb624bad5c758e5adc,2521110928,
p,x86,fr-fr,c;52c657286188ae0ff2e4dcb9e19238affbebdd95,2431461582,c;51175bc8447a6bf82b742c2bedb2513ce3c26772,2542532614,
p,x86,he-il,d;294bee60f7d248b6766c331ed6d291f23cab54f3,2282465040,d;35d3f60ebe22ba28fe51522a71d70269944a8789,2457645752,
p,x86,hr-hr,c;453579e6e76c81fc72a2b78b554c8cafaa4a23b0,2265497235,d;a1c6c6d83e61563a5b094e59f9591d4a48430236,2433167276,
p,x86,hu-hu,d;237677d16e6f2256687a02e2c07d44042ec4a5c6,2284059150,d;4d5d740d8b644610fdfc403f09c75e471dc48fa1,2443048982,
p,x86,it-it,c;86b071f191f5193270378258c69814988df0f10f,2312619924,d;cedc39f6ae98c61ac0647b4a067040b1a244c913,2500671908,
p,x86,ja-jp,c;f7491c42d0d64688df6630378657cc2bf725e89e,2526997792,c;5f3a233a97b3a824de588902db59175274e7c6fe,2623127146,
p,x86,ko-kr,d;6639d29ba6934b13bcd5bec97a10cdaf1cdd30c7,2337854332,c;b5908819eca098113bc9ef3f763a1b75aad14b84,2511427192,
p,x86,lt-lt,c;1d142359840ab83fb067468cbb295845d07db385,2256006622,c;09c68f4e38d2b94671012239cf29867671999271,2429889618,
p,x86,lv-lv,c;2a3033731f8b28041fbe193a3f718cc62a301e6f,2260414882,d;71d5489b02a14a1ff7eca965ceb9833f19627447,2428535640,
p,x86,nb-no,c;5c5e576148999231f138597401cb14f25ea15829,2279262560,d;070a95e2239444b095e94bb42d1d9da70f13283b,2441045070,
p,x86,nl-nl,c;823da75e12b4688f0e08acb6efa686266c91d3fe,2301425470,c;0149b5bcb08496f561e962adf8bf4bb4eb74dae7,2453422694,
p,x86,pl-pl,d;df3a74d6bd322219e33031e7e97c7ad7ac503bc1,2284329308,d;07c08c77c8932aff2cd74aa51f25767200fb2d05,2475957478,
p,x86,pt-br,c;70142b3f23e729829b377ec56941cfa41c723204,2337652576,c;b57a3631b25084d4608c1297d80d6aaae245bc1b,2503293424,
p,x86,pt-pt,d;b8b1c20b0cc4383b54c6547f295ad8e8a7897d2e,2293680178,d;04c8f1dbe58217d0e9ec83570dc205002d2fbf62,2473189542,
p,x86,ro-ro,d;5ce741cb144a804e2281c8476f9c65f0b4a1594e,2263202628,d;6f3b6a6d0129fc638f0183fa02e9c06a46efbf69,2433641874,
p,x86,ru-ru,d;517619490219771a44196bb803dcc099110d9e05,2331906278,c;b7ce8535a9d98b725decd942e0d3be30754a0575,2499856318,
p,x86,sk-sk,c;eff3680bbbd0b45f27dabf4a054606fd78b30422,2258865734,d;1a19d541a7d730b039e8df7dd7398bfcf4830291,2434620244,
p,x86,sl-si,d;736233c3b0da875665d9fd8abd093771352d4608,2255942595,c;0e50d975b2fe90a58aecc3c7cc201457f435c025,2429892232,
p,x86,sr-rs,c;2d44d42cfe870638ee5d517da54f3286790decd4,2264817096,c;00596ed8b28cfdc923415ce6331866b81d91033f,2432319216,
p,x86,sv-se,d;9b7ad348af69829d1adb57d12f5315bda42f6ecd,2303368688,d;74da5ba69fe1e6910f3cc9a085a794f12e22ef58,2445959076,
p,x86,th-th,d;2676ce00bc5b187ca87dfbae04226471b3bc36ec,2275252504,d;67f63c4d073486cd33353f450883d921dde35945,2450007156,
p,x86,tr-tr,d;250c7ec09eaebb90681467d906ba22f5aab890c8,2276829342,d;b6a86891756286e3ba6b1ebd4d47e59c0c1cf5c1,2448261418,
p,x86,uk-ua,c;47ed1f3b95a08c706e13f5b4afb5e4ae0173a56a,2287688882,c;4f4683215f0b795a943992677e989e4977016227,2453351344,
p,x86,zh-cn,c;bf32e2b319724e7fc6765330c55888cc3eda6637,2492418640,c;a09759e7eba5eb47e1714ef9fb90fbb9b8b16926,2693248436,
p,x86,zh-tw,d;e80465b8395ca5afe4a3002519d2f100514f39eb,2437070118,c;b04b61789de4357e5b558e3304d251be84717905,2622868522,
pN,x64,bg-bg,c;fc329f5b4f683d6c9dce6da8ab12254f4aee79a2,2773968628,c;5f44e18a89a33ee13c3f58956e2875c4a69e4339,3062965392,
pN,x64,cs-cz,c;c8c121aa245eebedef4142d86e8c444c82eb5ebf,2773293502,c;eab2c98d358e19006bc5501eb376eb78c5f61ff4,3061390492,
pN,x64,da-dk,c;01fa575f4e02f6d7b63cf02f691cdad8b7d06385,2797523030,d;b16e9860d40df7b56e1dd6ac5c66d3695ca605ac,3071035468,
pN,x64,de-de,d;dceb5a8fbefd5c891523cdaf7d9ef85ba78648ca,2887386902,d;b4f3bf648271229e67c02d4a9c3e928f59671182,3174390478,
pN,x64,el-gr,c;33997af7aa98ddf701dd77a197a01ada0083cd16,2801821428,d;ba6536791a95ddde7eb6d2092fbe4dc256263bc3,3058180776,
pN,x64,en-gb,d;91815f5e30a2b75891b396c8a0b2848befaeb46b,2859609418,d;ebf08fbb1b8a857b5ddf615ecdb2e05576fde6fe,3138889370,
pN,x64,en-us,c;eef8273e5aff097f031d3eced6081a2ff1ce6e70,2859983836,d;8f08b14b8e4215d95df4aa8f6677c442f3280608,3134074578,
pN,x64,es-es,c;28c0c3facdee14fca9c415baf12e852424cfe823,2849603408,c;e980e0e4d391747c5079b9bcf8fa02f3610dadf8,3147378694,
pN,x64,et-ee,c;956dcd0e2e74458d9c530837e76e3e85c87569af,2749178492,c;a5459eab69a630f6de0f5f7ed390d80da6287d1e,3033156374,
pN,x64,fi-fi,c;2bdb6ac2dbc58954f7cd24270fe3e90284e54daa,2797659170,d;b41a9b486513d44ea20c0036973ce7e7e5677d2d,3058342604,
pN,x64,fr-fr,c;2911e901d843d85ff7d4d8a26df117c915739d1e,2851575648,d;7b1918b7a43b5c484f9604888dfd571eb5ef989c,3135241050,
pN,x64,hr-hr,c;2bb2b9c596d7c58a152533c0f68c193dff262f7d,2765117444,c;83872704fe26c66dddb5588c43d0c5105f0a8e7e,3031238450,
pN,x64,hu-hu,c;650ca39bc961abf7798fa7877bd44bec042426a0,2782768444,c;dfe00bed39f3293acedfc60d4703b093b627c1bf,3046729422,
pN,x64,it-it,c;63287c51ff616254966ed37d52ca9300cbb12230,2800506190,c;9b988be77d94a9ceecfdd3c0aeb1a2921f3b3ab4,3100978042,
pN,x64,lt-lt,d;33ce1e39bcd256df8476f189e5a6a051de49cd13,2754636784,c;0712851abb0163df81f8692ffab04d6b1b19c7d5,3028157126,
pN,x64,lv-lv,d;fb774f04e2f477d5060cdf15ccb67a57471a5511,2755350776,d;d1678361ca61445e7e808a67548dc37292ebb2af,3028725540,
pN,x64,nb-no,d;c1a2d7a1b2a5215831439f80a716768eabea41b9,2772100158,c;326efdbe48d12dfbf7fb5be385d99ddf9891c464,3059758392,
pN,x64,nl-nl,c;e363e17767440f8c902e96ab193c926610ffadd6,2773104714,d;834e4a5b1ee8a34ea6d7ab97d1543727ef07f066,3058822848,
pN,x64,pl-pl,c;695623b0a4f468c1dd7c5807faf84dfc9b9356f2,2780436314,d;f503b82af5c2a1d7d3db92867c7ad8ea8c506e25,3078483218,
pN,x64,pt-pt,c;5d54830d399eaee9d14223f9085684c5182cdab4,2788551940,c;105e7656ad4f9472f46a990e9af6fc6008bb0299,3076144756,
pN,x64,ro-ro,d;d98b84579055ca2114bb86390def6a06d4450e40,2765807026,c;07129c8b89771ee78d55b28fa0235eb5fbc203a3,3035255674,
pN,x64,sk-sk,d;fef5249e7b211a31db3c756f8746cc69093b8f89,2762718640,c;96df6aaa8c80e17a364518e4407ec341654b7312,3038980680,
pN,x64,sl-si,d;ac0ede2cf10e95a905f4070bcf08651625d8cf6a,2758415634,c;3e44dc84aef2463ed56352740a0b170651acda74,3027672078,
pN,x64,sv-se,d;1ed5517d01de32c3cc1f77cdecfe4f356c0d94c8,2797681810,c;451e5df2b8a32f7bfd04ed1b20737a16b0a3d770,3055257762,
pN,x86,bg-bg,c;ef1cdac011e2796516bb2ecd489f5a95807db56e,2111630422,c;784397435172346058dcddaaf598f50c1106052c,2342230796,
pN,x86,cs-cz,c;c2fb76d2890cd7b33759d070bd4fa9daed67839d,2111595264,c;f7d6e4300851b880570a4b42c290ea43a51e825a,2340828822,
pN,x86,da-dk,c;6f3a269b3f46310845cc4671753f9bb5e0c53fbc,2137463158,d;1705dd7e86d7afcf517c549a94e2db7a445b595f,2357616126,
pN,x86,de-de,d;bfe79458d02aeaffbff01df43e43af6cff1086a2,2220146562,c;3d1516229572cd93b7aa643c5afbd38f6208e9f6,2468947694,
pN,x86,el-gr,c;93a91f0147950b7a92f1b52206d4185d5fe2adf7,2120864956,d;d2b7504700e688f39d66a773bae8f0e5ce34f79b,2358200780,
pN,x86,en-gb,d;00f726c42be7c11b5fa7761cc26f9957880d1324,2198424742,c;4de9f2360f0645a3fadfab850f9ab48762573d78,2427693510,
pN,x86,en-us,c;5e29955a7ce81907f0d90f61ef0c87a4d5693150,2202017206,d;a7497ef7aff694250be967d2d10c6116a5d26523,2431422208,
pN,x86,es-es,c;cd2c62a7e75b6d0afe39da402b63b1f042b2ee60,2195845498,c;a08ff7d5dfe25eb51d56341c4df866577c6e5e65,2440408844,
pN,x86,et-ee,c;618bb7a7e6305ae5a4ad05417c1d7a6d1c240d94,2095309794,c;0a26ea09337519ba115f21b78e3f0aed0ab45b0d,2320456032,
pN,x86,fi-fi,c;8c673bcaf88ff3675573a358be304962900a6971,2136318712,d;bab89eeb930561e0140eb12be7a06d6df16476bc,2342355544,
pN,x86,fr-fr,c;eb7fd4ca93539d05478dec8ee088184df9ad340b,2199089480,d;1fa92c0dd81a6cac8efa741d27d6902f04f5f941,2432693414,
pN,x86,hr-hr,c;90a92a7b6a6ca30d4e0b609178c9aaa49c0fcc28,2100765434,c;0a725ce083bacfcced9022209bef12ab5dfdd58a,2327449750,
pN,x86,hu-hu,c;7407a410bf6d9573cb22b06cc98ea8467f0df658,2121777568,c;0aa88a593232240db6c89ab9bcd3d994fe047f8e,2342265870,
pN,x86,it-it,c;f4863cd0ecf5bfee974b9c423c9d864e9bfba3b9,2144659586,c;8d67fd32d106b0d7ab3b8375a013f681cbba1dff,2385126888,
pN,x86,lt-lt,d;e2db5267355217e8f572b6b482b5b15e0ae85121,2094530112,c;37b27db921300461795edcaae085528735fa28aa,2326102028,
pN,x86,lv-lv,d;a342940c936e67f0f93c433c935b868d58d8867c,2094597898,d;fcb378ef59b277223986482e8d0528608f74d4ff,2326564272,
pN,x86,nb-no,d;c850d7cc8aa9b5c6a1f443efb313482c9e01fa12,2113869760,c;c485cf3d979b1d3e85f249d39489c9c7ae077720,2338122848,
pN,x86,nl-nl,c;31f1d6c1735d862d9c4a5aad54983b9ac691dc3e,2131740526,d;9f9538de6a63c6eb9a510c1edf3f8dbf7c885dbf,2342693286,
pN,x86,pl-pl,c;947f434e5f736374f797083686d156ac31f61cc1,2126498562,c;44d11c4f07f54617067a5c50a37f23047b260ad1,2363883710,
pN,x86,pt-pt,c;76f04e40fda45dccb6d056d3a3ed629f3574f0c1,2128468318,c;53e8e14cfd0703bfd4d529e4a6caac2352d117da,2357325274,
pN,x86,ro-ro,d;c399fc45669d57ea42a650cfa1ef9cff42aa6315,2099203004,c;672763eea048eabf9d2561532a051eecd3447d93,2328716638,
pN,x86,sk-sk,d;24cc2caaa234990688701aa259fc99740f6cf625,2096757828,c;b5764a025eb14227a8d48a23fb53c9af2e0e2032,2329998398,
pN,x86,sl-si,d;0bab0901bdd35b2e1bfa11db4d31aa835a79d39b,2094438534,c;3de28a415bf6d3424387b91e5e8d54219785fa7f,2325483758,
pN,x86,sv-se,d;7b3ac33040f23a1d3ca949124aae5035270f0e0f,2129967952,c;d226b50b2dd9f995d4080b98030bbabcdafe76d6,2341328688,
u,x64,ar-sa,d;ad209ddde42bb7c0dbe62aeaa56c9edb1e21374d,2956949156,c;75bf847f81faae21d85ce27bc2ea5081df25cdfc,3251847572,
u,x64,bg-bg,c;d5c152271d498675f400eb335c7f20c8f05cff0d,2913342796,c;c6ead57dcc61d87f3c43b78526fdbbe78d912377,3206626386,
u,x64,cs-cz,d;abb6ab1ab0b5a9f9c715d1cf91aa473e410eb958,2917449894,d;031224c662881365f2a971dfe42ea342c9448796,3207310586,
u,x64,da-dk,d;4641e22dd93423212b5b465db1c4b720921ff737,2945166370,d;60aba504f24ddbb177c94edf837ca85c21662fe0,3226462806,
u,x64,de-de,c;352e4a7510e0ceaf1d97f03db3579af3e0344938,3018157658,d;fad7f186a2e646d16a6a6b56f11b01ee0cc14f1f,3327083894,
u,x64,el-gr,c;93eadcdc4ea4b3c9464de64898fc172284ba3d24,2934720002,c;c51af64f28ae99c28a3f453365195ded29aeeb2e,3226390944,
u,x64,en-gb,d;d363257e8203c0b46c98bfbaeac8e50d6d762f91,3001730482,d;d2fd393536a0910ce1d69eb94dba465e24a545fe,3282224232,
u,x64,en-us,c;01e49055b446024d37bdd3ad1711a8b529bc98df,3014778678,d;5fcec6f04b988820c7a7c9324e1d8a78e897efd2,3283493420,
u,x64,es-es,d;8b396b404a5e68b22570bd9d2c7bc23e0cc2fa89,2999917512,d;c2cf0c41654a9f36b7788210ccc07b98d353b63a,3293989448,
u,x64,es-mx,c;b16befdf9f8905fed73836a03a1505968b2aa583,2940854936,d;9f9d726cd46235d4ec471c8ade9a0144a01512e2,3255353974,
u,x64,et-ee,c;6edcaa2167c569b5e3dac218f90161f686eb4ea0,2890533510,c;8bc1d88e96a8b5563bc153cc3fd2ec1e558eeb70,3173983282,
u,x64,fi-fi,d;88e07bcb494c2973a37eb32c11c6b2f6f313d6cf,2936951164,c;9d0403b9310263edb3fa8e4926c033288d5d77dd,3211676114,
u,x64,fr-ca,d;99dff3ff2faac319c38b67adbbf7df11b996e2f0,2972513666,c;1afa5bfa09a0bfa82187f93ebeb72327c8babb75,3267937290,
u,x64,fr-fr,d;c4aa11238240f052fc155a69add5aaee5a8fa2c1,2993414936,d;c13e3a943e43a78b77954fd490ca9fddd613e36b,3280449890,
u,x64,he-il,c;ccd6fcf5bba100f8bd7416b8368ae88986d42719,2919856152,d;35fcaf72f58e39dfef29d1bc2ef909e18e4e3e8e,3211561870,
u,x64,hr-hr,d;373e5f74e3bf90e1e40597b2907a705cf7947ab6,2893579680,d;371dc050f05b667eb0ddd07f4628a6e2f6d8bbd8,3187910322,
u,x64,hu-hu,c;9c2f593daf664ef8b2424c9b85ec981d957b96b2,2914578404,c;4dff1276e483c996460413fde34f4ddb2d82ec2b,3198669702,
u,x64,it-it,d;be99f0766321e460a071d50083a758dfacc64923,2966090488,d;1281c83d18b4a3f896b12d503fb8c04e574b579c,3252699004,
u,x64,ja-jp,d;02e4b9da921626da3d03c0a413ae76148dc0f9cc,3061128986,c;5d61c365a23b3b1af2e52064b8d9403225f98d38,3380955790,
u,x64,ko-kr,c;77018ee745ebdc581693dcaa9ec8697b5605dd3b,2966153026,d;72ec8182516a922a2790559421e3dd7a12076588,3263151432,
u,x64,lt-lt,c;afacc60cf3c558d94d01691f896a303cd3455651,2886584406,c;91811ee67098cfc971e0beca22b204f61638cfab,3171495573,
u,x64,lv-lv,c;f36bada74914782fe174d92bf82222e7d5d61488,2884763892,c;17663ddefe2473ed47e1ab3021aecb49a2911957,3170436086,
u,x64,nb-no,c;330597e50d041b5f9e1798671aa0857ff9dc2e3a,2918231688,c;36959196b44da127aea969a96024af7e09de1032,3205527402,
u,x64,nl-nl,d;5fd638867eae87b871fa1d0e393866698eda8514,2929881030,d;4f802d5a36d6d129446419d00faf96c60f574ba3,3209719614,
u,x64,pl-pl,c;3e48dfc45ec6551ba7b67ae6c965351e5b0c6263,2930550878,c;169ea673afe3d895dde85efbee23ddce221f44f6,3228161764,
u,x64,pt-br,c;5e453b92f20a8713b7ca6ecc5c2f2577cc67b58a,2952864672,c;9c8ee58f9ecc4c5748166e10788b7aef771491ad,3242537098,
u,x64,pt-pt,d;6135ad949cdfc76b4ebd0375f83ffd49ea09d80c,2928144706,d;c02515d94fbd41341f59025a2c89ebf87dabfd29,3229372742,
u,x64,ro-ro,c;1d231962d9263ea94c7a094565cae9e22f95e645,2904204054,d;0407c402d5a3c1c83d4b8a30cfb01747f72385e4,3185051694,
u,x64,ru-ru,c;c5496123d5f1ed75a8511ea6c71c958bc38915c8,2957672236,d;0a35728822997a3290ced87d63dd0da3f20435fa,3247965106,
u,x64,sk-sk,d;07e05be074dc12e411b3d1c5cd144a210b70e869,2893555152,c;5fd6a7c13e5ad9dd90df492087ec24d814958abc,3193305246,
u,x64,sl-si,d;6236323d5ddce9c6d1e5673c13ad2232d8d8f1a3,2884411810,d;dd4fc454cf52c17cc1d3c65cadad865ec39cf331,3180336710,
u,x64,sr-rs,c;534d4a85ae9a935f7ede65e352252ad27e90f21f,2891648167,d;1b5296f5a5974bf00111a4e566ef945c831ad420,3186224050,
u,x64,sv-se,c;67ee08ce7dcdb02cb063a40129afae15a5e7e774,2942914320,c;95250cfc844f35e2882f32671ae1de8c976c4fe5,3201626294,
u,x64,th-th,c;c341908be3ecdbe7150a763b900cca194befe662,2909426878,d;ba005f9b74ee05f93746bce839dc877360e28922,3201916226,
u,x64,tr-tr,c;3cef4a469646dd673562a2990c6fc99c1d57af3d,2917813760,d;257208062c06e87b315007769087170d277d4a69,3204014662,
u,x64,uk-ua,c;e7e3090d392bc59e15da7a49be08772a15d5c2c7,2913314734,d;b843e99042a296e35f0821816a2ad619a5395c3d,3206768732,
u,x64,zh-cn,d;120476969142efd3701de14d140be47cf84d92ab,3137548350,c;2a825c67608ded61192a63bec775096213aa5205,3448766646,
u,x64,zh-tw,c;57c2708dc6583a3ba6005e04934bc07541626da2,3058815872,c;0ac1ba13c4ec709fd6edfacd6584adcefa626aee,3384825764,
u,x86,ar-sa,d;d7e56ec015c48a9ad24671c6ef1d80daea27f189,2254502852,c;4cf10443f278587cb72900324884908d8441c407,2492824508,
u,x86,bg-bg,c;225b91d09bd7a639fdabe14b7a82bfbb7abf5ba9,2227290394,c;f48b253b765dff39881651030268c09392de1555,2449636070,
u,x86,cs-cz,d;dbde988b353a76740e0576b53005cbd5861ef1c7,2213609352,d;3e56ca36104feac70f46cf7ea0a8853b1b500b3d,2447727068,
u,x86,da-dk,d;2a892143d6eaa1dcadc8720eb890a1db7a03b28d,2249489774,d;ef137301727174a08df1fb84743469139bc4e925,2467425384,
u,x86,de-de,c;a691d8569c4dd10f4831d8ab9c9bd87d7b3b918e,2319600702,d;d1f9c856dee75466ecd396f027aabaf640fc2122,2576555370,
u,x86,el-gr,c;6c7b921c6798ff2a8128bcd6130962f923064642,2226151718,c;535d32d74692fba745c4f3241549b949d76e5d68,2467105860,
u,x86,en-gb,d;6542537ae4a5b1d76c2f7658b91ccfdc84005dfe,2303122652,d;0673fd68d4acd8c079a35a2213b06b318e05ff07,2540526024,
u,x86,en-us,c;fe55e8afdcc571f8e8fd5a42cfccf14790d89cbc,2305264922,d;6e18fed58e3ca6097828e0b85cb9d71a6e812b47,2541035512,
u,x86,es-es,d;6aaf073db8890a7c6aa6214633bb345cbe9a82cf,2297447302,d;0d30a4ee2fff7affecb4bdff17eb67e9bc935a7f,2546176642,
u,x86,es-mx,c;79d8fa9f21f4f689ff2315d669e584058c407b69,2245392276,d;5024e49e1c0ab3b0d7db5405dc1a835c5e82529e,2493052572,
u,x86,et-ee,c;7b4c97f368a2673f751a9e1c98a79a65ec846b74,2190464570,c;20605729c6933a0d6e4dc02a03df3d404c9923ed,2429343544,
u,x86,fi-fi,d;44c3d9b0f171337f3e83cd4b16b9fb04875b47c5,2232027472,c;152a5599fdde049965f043ef4cd3594f725177a0,2443850910,
u,x86,fr-ca,d;01a686ce606798e63eee51111ba600f832cb867a,2268537776,c;b9eef07b0f4c8d398b452a02e400e2004e1060ee,2520135272,
u,x86,fr-fr,d;e9e686f6bb0e5a2bb463969aee1ea0bec3cafa16,2298742674,d;6d2c95ab1708554903effed98043384c07009ce1,2541782742,
u,x86,he-il,c;135c9d913514fb9ce8c0e3a11365c1f7ec96f7d4,2225234406,d;ccaa33207aed1be2676b952e216b70c27b0d44bd,2457389036,
u,x86,hr-hr,d;a97c9fd5d866cb6b49f5224c0e227923335b071b,2203786466,d;d47d0ef940827000c610141a20244be8db49e093,2432051490,
u,x86,hu-hu,c;24e79499a39c3f658a4721f0e64fc99f80eb71e5,2219026456,c;3f21594fcd99429f43a134b2ad705a39a6e93a23,2443321470,
u,x86,it-it,d;907c1dba70eca9011e7a4c087b76edd7d4ead76f,2247919526,d;2cdf05c94907e814f86875c69a33fdb3f4afa56f,2499266318,
u,x86,ja-jp,d;6511fc807e5213138c36abe22ca4b9e7c9e43dfd,2356394260,c;4c232d7187a7deae3b7a442becf86e83aa92585b,2619755766,
u,x86,ko-kr,c;9e869188c0d903fd0d982f93076960383d6b608e,2259563116,d;60598d7cb17d96b714e8c1e46331e8477ddfde26,2510631222,
u,x86,lt-lt,c;593f59fabf626765463001023aff98a29c98e713,2195909696,c;cdeeab36d55a0697a857988ba3539b5889a0b667,2428993596,
u,x86,lv-lv,c;d520a5c393fd148b7e0af4fafca9e7381b5981f7,2194102206,c;621cb2345a0bb589f11aff848467e52a64b4aa5c,2428345960,
u,x86,nb-no,c;98468450afb526f4f16f5c791ecad934f1ad99ce,2217842192,c;a58a554d48058666f6ed04f656e7679cfeb69532,2445596626,
u,x86,nl-nl,d;1b68236863ec2782377eb23c4897fc371e5d082f,2227957810,d;cb9d8986c2d5d3a5845aac14e311133228184854,2451085940,
u,x86,pl-pl,c;d2e0f7a4d26c8f52d136d7bdae162075edf70757,2226921692,c;454e63ac6d99ea6627d7841bc0410875b5ebcc6e,2472848030,
u,x86,pt-br,c;34066ad64f0066280ebde3b7833f89c7e468212b,2254176436,c;2425c7a1c1d5f265c67fa7c06b5ce4459b305214,2503136758,
u,x86,pt-pt,d;fe0f33f8faeffba3c3a059660802d9c44936c801,2228686892,d;84fe29af7992ee44492f232c4be3682d03c86ca8,2470097536,
u,x86,ro-ro,c;3787c9449e922cff784347f436f0e10b11c83588,2203396506,d;a197a2dae04fb628ef7d26afa7fb916168425a5b,2433381486,
u,x86,ru-ru,c;e01b56432419748e3420926222512f8b464509ca,2261036400,d;71d32106405319b240dcf070f7685b3d1832e77e,2499430086,
u,x86,sk-sk,d;703136264909e5333044aec874ad6fb14790eedb,2197058184,c;9cc504744b4aa015b221185332454ef7b16ab7be,2433557044,
u,x86,sl-si,d;a92efb6ebe2225fffca570d46b9bde4dcba732f9,2195839708,d;f8bed0bf249db18ef548358975e522cd5058ce80,2429463296,
u,x86,sr-rs,c;8d504ce35fb48d0e43e4b0129f80157991f93727,2201558184,d;cee1f8554f96a20ab6f2cafbf97ec64fc8ab0cb0,2430903936,
u,x86,sv-se,c;5b7f3a60a484b8ab7ea57629974a6df187bdae48,2230458544,c;bdb42eeac01c6f273523b5acf72eef383a0c74b4,2445395424,
u,x86,th-th,c;df73d20b5559e717b965b762741795630a253877,2216567444,d;8d24243de4efadbae4ad505b7d3ac9a911215675,2446891086,
u,x86,tr-tr,c;e53d36d75762b89914ee1787e220ac10dfb5c5f8,2215387172,d;419b90478352a0ffb34a4acda6ad65b8c3007a44,2445522614,
u,x86,uk-ua,c;b70d87de530267e650ae34b5b29b5a316d69cde6,2220722110,d;92d482a317102c5c9c0d82c633dc2224a2e9d27a,2451238526,
u,x86,zh-cn,d;32e7d27d988f97b5b77e2a371035c9b80ee23b48,2421638284,c;1c5b9c6233824e29683eab03a330597043be909d,2692947978,
u,x86,zh-tw,c;2237f1fb22a928df1615afffacf3bd916a188728,2359003730,c;6d88e81c026f66d3873622cd852f59b511031388,2620904612,
uN,x64,bg-bg,c;7a3b8f8df4d678a1e7a34e341fc7d5618ec9a246,2779059020,c;a9b6ef650c85369e3a4f3f7232fdc7749ad0bd47,3062413646,
uN,x64,cs-cz,c;ccf1326afdb7d2641360f79e096e49c6a38ffa32,2776622382,c;9e43e3051c6142fe660ab4bb3c9318750cc7de93,3062757590,
uN,x64,da-dk,c;7406eda1d78d6f3a7e8a1bb6370daeff8a28821c,2798017588,d;aeea7197285823c6c337af2d71ce8f922ff03bbc,3063187452,
uN,x64,de-de,d;64b3d9d55cbda469d5228ccc9156cd0fc23e04d4,2887254906,c;fb0ebc0aa2ec1df782f6d5a5f18202df98907153,3174260636,
uN,x64,el-gr,d;6d69df40a7294e47c4e1ed4dd97407df71e3b579,2797909794,c;d4185e6aa65f5679fae8ae794ca94e75ea843016,3067640890,
uN,x64,en-gb,d;1178f5a038534a6db054c0587795827c8174a3b7,2856936794,d;0d11ae99ec511df9f9e61f860737dd1fe30b4206,3137052746,
uN,x64,en-us,c;9f9054a5831a86799435742b96589d35556e0b33,2861204596,d;d534aa4085bf14c3df828c5af83032b79cec8bf9,3139755962,
uN,x64,es-es,d;9ce4a7149f1c83547a093c77e3a054be2facd930,2851148850,d;233790bf41149c751d40811dbfa9c64f83553d8e,3146456906,
uN,x64,et-ee,d;1ed1164e84604f09732a9837adbcd27b45742d16,2747120942,d;643c5c146cfa48609ab76e718b08049fe371100a,3031709940,
uN,x64,fi-fi,d;9798bf4f02717618f71ab3ec9919e4c304b24ea8,2798444234,c;41898f06c71bba38c74c5c501f4eae437ec41695,3061874646,
uN,x64,fr-fr,d;b80067fe56f542be1e2262fd1f93ed9bf45de7e6,2851527218,c;340507bd08c569ad54e992eaa20bc5b094887bab,3132546598,
uN,x64,hr-hr,c;35d1a05b4f329e42e0d16930b6cde4122c40f765,2768580546,c;1af71d7b368e2f0fa31bdc415f9a59fc7d1490df,3032743718,
uN,x64,hu-hu,d;1a108c29a93bc32e4a1fd28c73e99ca88c5fc1c0,2782140028,c;2ae5ec7d0ce1566d5f1981d2e5b0c8f19b4bd24e,3055842566,
uN,x64,it-it,d;7521153898da230759cbc5a3b7b6534d3a378ef0,2811926886,d;ef21e54b4149b2fcd67805d966fff614ec6a23fe,3099583308,
uN,x64,lt-lt,d;f0385e16fa913fa76719383e850d1d35070a92a8,2757803852,d;bb5814b37ad1c338ab6fc73446d255e4a0134ab9,3028908668,
uN,x64,lv-lv,d;7792ef1b2b8bc3c5b8c217d0748da5b8a23eea07,2756086022,c;0ef2a40575f7cf5110609b53d454e203145132f9,3028644192,
uN,x64,nb-no,c;ff125d34aecdf49b9d1540d6061cab57dc7e39a3,2773327388,c;66f8d9a1a6a8070eef3f80d00df333d9df61fc43,3058575164,
uN,x64,nl-nl,d;e4d76ea47cccc8d3c917d5d86325903a9759e1f4,2777477440,d;48c9f2807b869bb00a9ba1241424a38f95612ebe,3062067296,
uN,x64,pl-pl,c;b15363bc8841f93b28d285220a9ad7786e1ca9a1,2781418062,d;25becb5821e972dd606bd9155740a99ae7180a1f,3080456656,
uN,x64,pt-pt,d;b7810c3c8ca4c1be162ea5cacb8eecf5f90161c8,2792216100,c;fcb4cc8a9defc6f31971aa681bdd04ee735487a7,3076125224,
uN,x64,ro-ro,d;cabebb3cdc5c3e11f839942ce96f76ebc24f14a0,2764183386,d;ec31c6800ea132e93dff86efd58a7843b05f20be,3029460788,
uN,x64,sk-sk,d;3abdf61dec10498ecd12df2570bffe4d11109e3b,2757427958,d;d3f1058d8bbbc21e81f1047a75b48b4cee0630e9,3035148714,
uN,x64,sl-si,d;e5b73905ef2020efc1bc646abe87a3ddd7dd7bf6,2758340722,c;e89e7e320308935f183c2b7a7e2e7cf7172511e1,3024798576,
uN,x64,sv-se,d;fd2fcdd512f2b38c3791426b3f8421b1041a9e0f,2788498688,d;0c40567e9a5e8d720ed6edf05a0cde9a17bb0415,3061608074,
uN,x86,bg-bg,c;66cc95cd28f00e40caee6bec7d5d70a8fb5e773f,2111252165,c;76ec0c3816f8ade33ffeee9615450467af80ec7f,2343495134,
uN,x86,cs-cz,c;f1a9bd1559dc919bc370f4166ef8ad86f10d73b6,2110545610,c;8ad87a656634d89236a6b32418e615418d5045d1,2339079508,
uN,x86,da-dk,c;497b443d71e65f6a63f01fb7ec61c53b8bfbdb6d,2144210086,d;2dc2a60636d961a67eb9496cb621113dcb582ef8,2359142738,
uN,x86,de-de,d;9213ab89e0c17890d3a9151fc79932a587f3ac52,2219606526,c;f4a2ca4545ba6a8166d4c3421849b6cc1fcb35d9,2468099010,
uN,x86,el-gr,d;94e7d1affe714552cd0d5dbacbd49eb48f3f1fbc,2124151984,c;d26d6de6ed08658921e5b702920370090e8b9592,2355660782,
uN,x86,en-gb,d;3eb8ee29ddf22f0347e51c2dc0b6e244c988c9e8,2200062104,c;14a1c43e4c7d7cf5a169257307395af0ef2e879d,2426880828,
uN,x86,en-us,c;3245de6b32dac4fe753a29d77c4d5276f752a9cb,2200128810,d;88743dd5e4c3b6d8ff2f6339c7a59d535f776b90,2430993824,
uN,x86,es-es,d;4ed9dcd6d9402c53b7c0d7ddadf29732ccd47ef3,2196419238,d;22593039f6029ebce3946a1a37292545b45071ae,2439392666,
uN,x86,et-ee,d;1edea61b5c9f927bb86adc4eb4b64e65f565f5ed,2096054254,d;cc868eb008d71ca38fc236e745cf5e27548c4bd6,2317447208,
uN,x86,fi-fi,d;8299144245d06af58bfb1787897e2601a4346bd7,2136693992,c;b5ed3b76897eecb07038496eb78dd05b032dce97,2341874174,
uN,x86,fr-fr,d;d67758e1aab4ba26e563c94c9e71f02bc8b457ce,2198063086,c;2ed1bf3706a82495959874e91b2a3a06e0a9e7b3,2435002592,
uN,x86,hr-hr,c;d9037e29d6981d000643004ac770e5e1eccfcfb7,2099953642,c;c18c5d1e09f39c547cc4e4639915f78f3161fe0b,2321673434,
uN,x86,hu-hu,d;f45cf9ff9c019ecaa9b9de14252aa950bdfeed91,2116985906,c;55751ed59fb161d34ddc3644f3722ae15dc424aa,2341763976,
uN,x86,it-it,d;e12aaf53fb3b43731394a90b052d522e53d4c3c8,2145186280,d;0e57750ad4aecb20870e58d35c0df1f76d494ddc,2384149974,
uN,x86,lt-lt,d;e5d410dee7dc702f1951f7a7a8a86590f605b302,2095722632,d;5d7619d4af7279b02bce8d4fe835205ffe470ffe,2326483892,
uN,x86,lv-lv,d;e41ce56ea65c5a80aae7aae51409c8353c89de3d,2095036762,c;6b430483aa0af8073b3a79f3ec217a71c8e394f3,2324302588,
uN,x86,nb-no,c;d0fb7c0f30e00ed68322a56f83502a84ca512b7e,2113411140,c;eb0d9b5b9a8325b13f264b14f7e7e1f6b99eb766,2337167608,
uN,x86,nl-nl,d;a71e61b4fb3a53e6346cdfae4d0a509b2c59b712,2122186926,d;146caf1f3bebf1be99c72c759ae57d033b159da8,2341747004,
uN,x86,pl-pl,c;e03523eb6a1426ac02da0db90e90da9ce24f242f,2121400542,d;6533b22e8d6ccb7867d3d97a01b5cc9e49e33541,2364261192,
uN,x86,pt-pt,d;af38dc63a255f96722417a390bb29625bd5f2c0d,2129997546,c;0fafeb7203697a8d61a0deea890321b3f0d89d16,2357048280,
uN,x86,ro-ro,d;7fde1bd5b650f7bd1b39da2c27a6cfce05cb58f2,2098687326,d;fc2cb8041993259d5472a13b561edcdcf213e54a,2329099636,
uN,x86,sk-sk,d;f77f86e70b997ef156cdafa5e3927c24d020751f,2096928490,d;07d3014138819d9681c48c5687be4bf2d75f26d4,2330490226,
uN,x86,sl-si,d;c1319abf345baf4c95a35dfbedcc0e3b9c206a59,2096845220,c;f25df37d61c88d58a7d746d6ba6159db712a70f4,2321416078,
uN,x86,sv-se,d;19d90b982ec2d963667561718642d3dcf2497cd4,2130648134,d;ae6dd7d66db41d7683af5157459bec97824535a3,2340666742,
"@.replace('sr-rs','sr-latn-rs').replace(':','/updt,').replace(';','/upgr,')
#: parameters specific to 1607 or 1703 expected via command line: $release $build $date $code
$url = 'http://fg.ds.b1.download.windowsupdate.com/'
$edi = @{e='Enterprise';eN='EnterpriseN';p='Professional';pN='ProfessionalN';u='Education';uN='EducationN'}
[xml]$p = gc './products.xml' -enc UTF8
foreach ($e in @('e','eN','p','pN','u','uN')){
  $n = $e.Replace('e','p');
  [Object]$csve = $csv | Where-Object {$_.Edition -eq $e}
  [Object]$files = $p.MCT.Catalogs.Catalog.PublishedMedia.Files.File | Where-Object {$_.Edition -eq $edi[$n]}
  foreach ($f in $files){
    $name = $build + $code + '_client' + $edi[$e].tolower(); if($e -like 'p*'){ $name += 'vl' }
    $name += '_vol_' + $f.Architecture + 'fre_' + $f.LanguageCode;
    $csvesd = $csve | Where-Object {$_.Arch -eq $f.Architecture -and $_.Lang -eq $f.LanguageCode}
    $sha1 = $csvesd.$($release + 'sha1'); $size = $csvesd.$($release + 'size'); $dir = $csvesd.$($release + 'dir')
    $c = $f.Clone();
    $c.FileName = $name + '.esd'; $c.Size = $size; $c.Sha1 = $sha1;
    $c.FilePath = $url + $dir + $date + $name + '_' + $sha1 + '.esd'; $c.Edition = $edi[$e];
    $c.Edition_Loc = 'Windows 10 vl ' + ($edi[$e] -creplace 'N',' N'); $c.IsRetailOnly = 'False';
    $c.RemoveAttribute('id');
    $nul=$p.MCT.Catalogs.Catalog.PublishedMedia.Files.AppendChild($c)
  }
}
$p.Save('./products.xml')
#-_-# :ps_insertxml: snippet end
