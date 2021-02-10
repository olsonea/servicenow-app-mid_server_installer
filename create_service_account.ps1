Param(
  [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_NAME=$(throw "SERVICE_ACCOUNT_NAME is a mandatory parameter, please provide a value."),
  [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_PASSWORD=$(throw "SERVICE_ACCOUNT_PASSWORD is a mandatory parameter, please provide a value.")
)

function Add-ServiceLogonRight([string] $Username) {
  Write-Host "Enable ServiceLogonRight for $Username"

  $tmp = New-TemporaryFile
  secedit /export /cfg "$tmp.inf" | Out-Null
  (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$Username" | sc -Encoding ascii "$tmp.inf"
  secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
  secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
  rm $tmp* -ea 0
}

# 
$securePW = ConvertTo-SecureString -String $SERVICE_ACCOUNT_PASSWORD -AsPlainText -Force

# Create local service account
New-LocalUser -Name $SERVICE_ACCOUNT_NAME -Password $securePW

# Grant user Logon as a Service permission
Add-ServiceLogonRight -Username $SERVICE_ACCOUNT_NAME
