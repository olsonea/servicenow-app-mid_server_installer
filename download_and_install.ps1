Param(
  #[parameter()][ValidateNotNullOrEmpty()][String]$MSI_FILE_NAME=$(throw "MSI_FILE_NAME is a mandatory parameter, please provide a value."),
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

# Get host name
$HOST_NAME = [System.Net.Dns]::GetHostName()

# Create local service account
& $PSScriptRoot\create_service_account.ps1 -SERVICE_ACCOUNT_NAME $SERVICE_ACCOUNT_NAME -SERVICE_ACCOUNT_PASSWORD $SERVICE_ACCOUNT_PASSWORD

# Get MSI file name and download the file if not present.
$MSI_FILE_NAME = & $PSScriptRoot\mid_server_download.ps1 -INSTANCE_URL $INSTANCE_URL -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD

# Create the install directory if it doesn't exist.
if(!(Test-Path -Path $INSTALL_LOCATION)){
  Write-Output "Creating directory {0}" -f ${INSTALL_LOCATION}
  New-Item -ItemType Directory -Force -Path ${INSTALL_LOCATION}
} else {
  Write-Output "Directory exists {0}" -f ${INSTALL_LOCATION}
}

# Execute the silent install
if(-not $USE_PROXY){
  Write-Output 'Running silent install without proxy'
  Write-Output $MSI_FILE_NAME
  & $PSScriptRoot\SilentInstall.ps1 -MSI_FILE_NAME $MSI_FILE_NAME -INSTALL_LOCATION $INSTALL_LOCATION -INSTANCE_URL $INSTANCE_URL -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD -MID_NAME $MID_NAME -SERVICE_ACCOUNT_NAME "$HOST_NAME\$SERVICE_ACCOUNT_NAME" -SERVICE_ACCOUNT_PASSWORD $SERVICE_ACCOUNT_PASSWORD -LOG_NAME 'Silent_Install_Log.txt' -START_MID
} else {
  Write-Output 'Running silent install with proxy'
  Write-Output $MSI_FILE_NAME
  & $PSScriptRoot\SilentInstall.ps1 -MSI_FILE_NAME $MSI_FILE_NAME -INSTALL_LOCATION $INSTALL_LOCATION -INSTANCE_URL $INSTANCE_URL -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD -MID_NAME $MID_NAME -SERVICE_ACCOUNT_NAME "$HOST_NAME\$SERVICE_ACCOUNT_NAME" -SERVICE_ACCOUNT_PASSWORD $SERVICE_ACCOUNT_PASSWORD -LOG_NAME 'Silent_Install_Log.txt' -START_MID $USE_PROXY -PROXY_HOST $PROXY_HOST -PROXY_PORT $PROXY_PORT -PROXY_USERNAME $PROXY_USERNAME -PROXY_PASSWORD $PROXY_PASSWORD
}

& $PSScriptRoot\validate_mid_server.ps1 -INSTANCE_URL $INSTANCE_URL -MID_NAME $MID_NAME -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD
