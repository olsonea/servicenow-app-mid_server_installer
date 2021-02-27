Param (
	[parameter()][ValidateNotNullOrEmpty()][String]$MID_SERVER_NAME=$(throw "MID_SERVER_NAME is a mandatory parameter, please provide a value.")
)

$archivePath = 'C:\Install\ServiceNow\{0}' -f $MID_SERVER_NAME 

$fileEnforceFilePermissions = '{0}\agent\bin\scripts\EnforceFilePermissions.psm1' -f $archivePath
$regex = "\[System.Security.Cryptography.HashAlgorithm]::Create\('([A-Z])\w*'\)"
$hashingAlgorithm = "[System.Security.Cryptography.HashAlgorithm]::Create('SHA1')"
(Get-Content -path $fileEnforceFilePermissions -Raw) -replace $regex, $hashingAlgorithm | Set-Content $fileEnforceFilePermissions