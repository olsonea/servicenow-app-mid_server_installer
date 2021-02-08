Param (
    <# Standard mandatory params for every installation #>
   [parameter()][ValidateNotNullOrEmpty()][String]$MSI_FILE_NAME=$(throw "MSI_FILE_NAME is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$INSTALL_LOCATION=$(throw "INSTALL_LOCATION is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$INSTANCE_URL=$(throw "INSTANCE_URL is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$MID_USERNAME=$(throw "MID_USERNAME is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$MID_PASSWORD=$(throw "MID_PASSWORD is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$MID_NAME=$(throw "MID_NAME is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_NAME=$(throw "SERVICE_ACCOUNT_NAME is a mandatory parameter, please provide a value."),
   [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_PASSWORD=$(throw "SERVICE_ACCOUNT_PASSWORD is a mandatory parameter, please provide a value."),
    <# Proxy Params - Mandatory if USE_PROXY is "true" or "1" #>
   [parameter()][switch]$USE_PROXY,
   [parameter()][ValidateNotNullOrEmpty()][String]$PROXY_HOST=$(if($USE_PROXY) {throw "PROXY_HOST must be set if using the `$USE_PROXY flag."}),
   [parameter()][ValidateNotNullOrEmpty()][String]$PROXY_PORT=$(if($USE_PROXY) {throw "PROXY_PORT must be set if using the `$USE_PROXY flag."}),
   [parameter()][ValidateNotNullOrEmpty()][String]$PROXY_USERNAME=$(if($USE_PROXY) {throw "PROXY_USERNAME must be set if using the `$USE_PROXY flag."}),
   [parameter()][ValidateNotNullOrEmpty()][String]$PROXY_PASSWORD=$(if($USE_PROXY) {throw "PROXY_PASSWORD must be set if using the `$USE_PROXY flag."}),
    <# Service Name Settings - Mandatory if MANUAL_SERVICE_NAME is "true" #>
   [parameter()][switch]$MANUAL_SERVICE_NAME,
   [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_NAME=$(if($MANUAL_SERVICE_NAME) {throw "SERVICE_NAME must be set if using the MANUAL_SERVICE_NAME flag."}),
   [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_DISPLAY_NAME=$(if($MANUAL_SERVICE_NAME) {throw "SERVICE_DISPLAY_NAME must be set if using the MANUAL_SERVICE_NAME flag."}),
    <# Misc Params #>
   [parameter()][ValidateNotNullOrEmpty()][String]$LOG_NAME,
   [parameter()][switch]$START_MID
   
)

<# Script must not run in ConstrainedLanguage mode. #>
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
    throw "Powershell is running in `""+ $ExecutionContext.SessionState.LanguageMode +"`" mode.  The silent installation script requires full powershell permissions to run. " + 
   "Please allow the user to run powershell in `"FullLanguage`" mode and try again.";
}

<# Validate INSTALL_LOCATION exists #>
if(-not (Test-Path -Path $INSTALL_LOCATION)) {
    throw "INSTALL_LOCATION must be a valid path";
}

<# Verify user isn't populating proxy settings when they aren't going to use a proxy.#>
#if(-not $USE_PROXY -and ($PROXY_HOST -ne "" -or $PROXY_PORT -ne "" -or $PROXY_USERNAME -ne "" -or $PROXY_PASSWORD -ne "")) {
#    throw "PROXY_HOST, PROXY_PORT, PROXY_USERNAME, and PROXY_PASSWORD should only be set when using the USE_PROXY flag.";
#}
<# Verify user isn't trying to manually set service name when they aren't using the flag #>
if(-not $MANUAL_SERVICE_NAME -and ($SERVICE_NAME -ne "" -or $SERVICE_DISPLAY_NAME -ne "")) {
    throw "SERVICE_NAME and SERVICE_DISPLAY_NAME should only be set when using the MANUAL_SERVICE_NAME flag.";
}

$instanceKeys = Get-Item "HKLM:SOFTWARE\WOW6432Node\Manufacturer\ServiceNow\MID_Server\*\" -ErrorAction SilentlyContinue | Select pschildname;

$installedInstances = New-Object System.Collections.Generic.HashSet[string];

foreach ($instance in $instanceKeys) {
   $installedInstances.Add($instance.PSChildName) > $null;
}


$instanceBase = "Instance";
$nextInstance = "";
For ($instance_num=1; $instance_num -le 1000; $instance_num++) {
    $instanceToCheck = $instanceBase + $instance_num;
    if (-Not $installedInstances.Contains($instanceToCheck)) {
        $nextInstance = $instanceToCheck;
        break;
    }
}
if (-not $nextInstance) {
    throw "Maximum number of instances on a single machine has been reached (1000) . Please uninstall a MID Server or install on a separate machine.";
}

$msiexecCMD = "msiexec /i `"" + $MSI_FILE_NAME + "`" ";
$msiexecCMD += "INSTALL_LOCATION=`"" + $INSTALL_LOCATION + "`" ";
$msiexecCMD += "INSTANCE_URL=`"" + $INSTANCE_URL + "`" ";
$msiexecCMD += "MID_USERNAME=`"" + $MID_USERNAME + "`" ";
$msiexecCMD += "MID_PASSWORD=`"" + $MID_PASSWORD + "`" ";
$msiexecCMD += "MID_NAME=`"" + $MID_NAME + "`" ";
$msiexecCMD += "SERVICE_ACCOUNT_NAME=`"" + $SERVICE_ACCOUNT_NAME + "`" ";
$msiexecCMD += "SERVICE_ACCOUNT_PASSWORD=`"" + $SERVICE_ACCOUNT_PASSWORD + "`" ";
$msiexecCMD += "TRANSFORMS=`":" + $nextInstance + ";`" ";
$msiexecCMD += "MSINEWINSTANCE=1 ";

if ($USE_PROXY) {
    $msiexecCMD += "USE_PROXY=1 ";
    $msiexecCMD += "PROXY_HOST=`"" + $PROXY_HOST + "`" ";
    $msiexecCMD += "PROXY_PORT=`"" + $PROXY_PORT + "`" ";
    $msiexecCMD += "PROXY_USERNAME=`"" + $PROXY_USERNAME + "`" ";
    $msiexecCMD += "PROXY_PASSWORD=`"" + $PROXY_PASSWORD + "`" ";
}

if ($MANUAL_SERVICE_NAME) {
    $msiexecCMD += "MANUAL_SERVICE_NAME=1 ";
    $msiexecCMD += "SERVICE_NAME=`"" + $SERVICE_NAME + "`" ";
    $msiexecCMD += "SERVICE_DISPLAY_NAME=`"" + $SERVICE_DISPLAY_NAME + "`" ";
   
} else {
    $msiexecCMD += "SERVICE_NAME=`"snc_mid_" + $MID_NAME + "`" ";
    $msiexecCMD += "SERVICE_DISPLAY_NAME=`"ServiceNow MID Server_" + $MID_NAME + "`" ";
}

if ($START_MID) {
    $msiexecCMD += "START_MID=`"1`" ";
}

<# Set Silent Execution Mode #>
$msiexecCMD += "/qn ";

if ($LOG_NAME) {
    $msiexecCMD += "/l*v `"" + $LOG_NAME + "`"";
}

cmd.exe /c $msiexecCMD;
