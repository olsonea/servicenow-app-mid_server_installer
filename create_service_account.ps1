Param(
    [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_NAME=$(throw "SERVICE_ACCOUNT_NAME is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][String]$SERVICE_ACCOUNT_PASSWORD=$(throw "SERVICE_ACCOUNT_PASSWORD is a mandatory parameter, please provide a value.")
)
function Add-ServiceLogonRight([string] $Username) {
    Write-Host "Enable ServiceLogonRight for $Username"

    $tmp = New-TemporaryFile
    secedit /export /cfg "$tmp.inf" | Out-Null
    (Get-Content -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$Username" | Set-Content -Encoding ascii "$tmp.inf"
    secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
    secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
    Remove-Item $tmp* -ea 0
}

$securePassword = ConvertTo-SecureString $SERVICE_ACCOUNT_PASSWORD -AsPlainText -Force

try{
    New-LocalUser -Name $SERVICE_ACCOUNT_NAME -Password $securePassword
} catch {
    Write-Host "User creation failed."
}

try{
    Add-ServiceLogonRight  $SERVICE_ACCOUNT_NAME
} catch {
    Write-Host "An error occurred granting SeServiceLogonRight to {0}" -f $SERVICE_ACCOUNT_NAME
}
