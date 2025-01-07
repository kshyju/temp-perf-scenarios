# Install Chocolatey package manager if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Chocolatey not found. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey is already installed."
}

# Install dotnet-sdk and git using Chocolatey
choco install -y dotnet-sdk --version "8.0.404"
choco install git -y

# Install dotnet tools
dotnet tool install -g Microsoft.Crank.Agent --version "0.2.0-*"
dotnet tool install -g Microsoft.Crank.AzureDevOpsWorker --version "0.2.0-*"
dotnet tool install --global Microsoft.Crank.Controller --version "0.2.0-*"

$logPath = "c:\\crank-agent-logs"

# Check if the directory exists, if not, create it
if (-not (Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath
}

$action = New-ScheduledTaskAction -Execute "C:\Users\Functions\.dotnet\tools\crank-agent.exe" -Argument "--log-path=$logPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "CrankAgentTask" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
