Param(
    [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_NAME=$(throw "SERVICE_ACCOUNT_NAME is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][SecureString]$SERVICE_ACCOUNT_PASSWORD=$(throw "SERVICE_ACCOUNT_PASSWORD is a mandatory parameter, please provide a value.")
)

New-LocalUser -Name $SERVICE_ACCOUNT_NAME -Password $SERVICE_ACCOUNT_PASSWORD

ntrights.exe +r SeServiceLogonRight -u $SERVICE_ACCOUNT_NAME -m \\%COMPUTERNAME%