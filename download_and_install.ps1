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

$MSI_FILE_NAME = & $PSScriptRoot\mid_server_download.ps1 -INSTANCE_URL $INSTANCE_URL -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD

if(-not $USE_PROXY){
  & $PSScriptRoot\SilentInstall.ps1 -MSI_FILE_NAME $MSI_FILE_NAME.ToString() -INSTALL_LOCATION $INSTALL_LOCATION -INSTANCE_URL $INSTANCE_URL -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD -MID_NAME 'Silent_Install_MID' -SERVICE_ACCOUNT_NAME $SERVICE_ACCOUNT_NAME -SERVICE_ACCOUNT_PASSWORD $SERVICE_ACCOUNT_PASSWORD -LOG_NAME 'Silent_Install_Log.txt' -START_MID
} else {
  & $PSScriptRoot\SilentInstall.ps1 -MSI_FILE_NAME $MSI_FILE_NAME.ToString() -INSTALL_LOCATION $INSTALL_LOCATION -INSTANCE_URL $INSTANCE_URL -MID_USERNAME $MID_USERNAME -MID_PASSWORD $MID_PASSWORD -MID_NAME 'Silent_Install_MID' -SERVICE_ACCOUNT_NAME $SERVICE_ACCOUNT_NAME -SERVICE_ACCOUNT_PASSWORD $SERVICE_ACCOUNT_PASSWORD -LOG_NAME 'Silent_Install_Log.txt' -START_MID $USE_PROXY -PROXY_HOST $PROXY_HOST -PROXY_PORT $PROXY_PORT -PROXY_USERNAME $PROXY_USERNAME -PROXY_PASSWORD $PROXY_PASSWORD
}