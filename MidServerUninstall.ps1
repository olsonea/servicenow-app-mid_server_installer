Param (
	[parameter()][ValidateNotNullOrEmpty()][String]$MID_SERVER_NAME=$(throw "MID_SERVER_NAME is a mandatory parameter, please provide a value.")
)

$installPath = "C:\Install\ServiceNow"
$serviceName = "snc_mid_$($MID_SERVER_NAME)"

# 1. Set service to manual
try{
  Set-Service -Name $serviceName -StartupType Manual
  Write-Host "Set Startup Type to Manual for service: $($serviceName)"
} 
catch{
  Write-Host "Could not set Startup Type to Manual for service: $($serviceName)"
}

# 2. Stop service
try{
  Stop-Service -Name $serviceName
  Write-Host "Stopped service: $($serviceName)"
} 
catch{
  Write-Host "Could not stop service: $($serviceName)"
}

# 3. Remove service
try{
  sc.exe delete $serviceName
  Write-Host "Removed service: $($serviceName)"
}
catch{
  Write-Host "Could not remove service: $($serviceName)"
}

# 4. Delete install directory
try{
  Remove-Item -Recurse -Force "$($installPath)\$($MID_SERVER_NAME)"
  Write-Host "Deleted directory $($installPath)\$($MID_SERVER_NAME)"
}
catch{
  Write-Host "Could not delete directory $($installPath)\$($MID_SERVER_NAME)"
}