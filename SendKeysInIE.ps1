#open IE > use SendKeys to navigate a webpage > write to a log file
#https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys?view=windowsdesktop-6.0

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
Add-Type -AssemblyName Microsoft.VisualBasic | Out-Null
$urlLogin = "https://exampleLoginPage.com/"
$urlTestPage = "https://exampleLoginPage.com/siteToBeValidated/"
$logFile = "C:\logFile.txt"
$textToType = "text to type on page"

function Log{
    param([string[]]$text)
    $time = (Get-Date -Format g); Out-File $logFile -Append -NoClobber -InputObject "$time $text" -Encoding ascii
}

function WaitforPage{
    param($seconds)
    Start-Sleep -Seconds $seconds
}

function PressKey{
    param([string]$key,[int]$count)
    for($i = $count;$i -gt 0;$i--){[System.Windows.Forms.SendKeys]::SendWait("{$key}");WaitforPage 1;}
}

#open IE and activate window
$ie = New-Object -com InternetExplorer.Application;
$ie.visible;
$ie.navigate($urlLogin);
WaitforPage 5;
$ieProcess = Get-Process | Where-Object {$_.Name -like "iexplore"}
foreach($process in $ieProcess){Try{[Microsoft.VisualBasic.Interaction]}Catch{}};WaitforPage 2;

#starting from the address bar
[System.Windows.Forms.SendKeys]::SendWait("%{D}");
PressKey "TAB" 4
PressKey "ENTER" 1
WaitforPage 5;
PressKey "TAB" 3
PressKey $textToType 1
PressKey "TAB" 2
PressKey "ENTER" 1
WaitforPage 5;
$currentURL = $ie.LocationURL

#validate and close IE
if($currentURL -like $urlTestPage){Log "success"}else{Log "failed"}
foreach($process in $ieProcess){Try{Stop-Process -Id $process.Id}Catch{}}
