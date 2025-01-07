param (
    [Parameter(Mandatory=$true)]
    [string]$ConnectionString,

    [Parameter(Mandatory=$true)]
    [string]$QueueName
)

# Define the arguments for the crank-azdo process
$arguments = "-c `"$ConnectionString`" -q `"$QueueName`""

# Define the action to run the crank-azdo process with the specified arguments
$action = New-ScheduledTaskAction -Execute "C:\Users\Functions\.dotnet\tools\crank-azdo.exe" -Argument $arguments

# Define the trigger to start the task at system startup
$trigger = New-ScheduledTaskTrigger -AtStartup

# Define the principal to run the task as SYSTEM with the highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Define additional settings for the scheduled task
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the scheduled task
Register-ScheduledTask -TaskName "CrankAzdoTask" -Action $action -Trigger $trigger -Principal $principal -Settings $settings

Write-Output "Scheduled Task 'CrankAzdoTask' created successfully with arguments: $arguments"
