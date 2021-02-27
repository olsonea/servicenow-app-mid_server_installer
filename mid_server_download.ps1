Param(
    [parameter()][ValidateNotNullOrEmpty()][String]$MID_USERNAME=$(throw "MID_USERNAME is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][String]$MID_PASSWORD=$(throw "MID_PASSWORD is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][String]$INSTANCE_URL=$(throw "INSTANCE_URL is a mandatory parameter, please provide a value.")
    #[parameter()][ValidateNotNullOrEmpty()][String]$name=$(throw "name is a mandatory parameter, please provide a value."),
    #[parameter()][ValidateNotNullOrEmpty()][String]$operatingSystem=$(throw "operatingSystem is a mandatory parameter, please provide a value."),
    #[parameter()][ValidateNotNullOrEmpty()][String]$architecture=$(throw "architecture is a mandatory parameter, please provide a value.")
)

#Write-Output $MID_USERNAME, $INSTANCE_URL

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $MID_USERNAME, $MID_PASSWORD)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
#$uri = "https://${INSTANCE_URL}/api/1234/mid_server_installer?name=${name}&operatingSystem=${operatingSystem}&architecture=${architecture}
$uri = "{0}/api/1234/mid_server_installer" -f $INSTANCE_URL

# Specify HTTP method
$method = "get"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

# Send HTTP request
$installerURL = (Invoke-RestMethod -Headers $headers -Method $method -Uri $uri).result
#Write-Output "installerURL: " $installerURL

$filename = $installerURL.Substring($installerURL.LastIndexOf("/") + 1)
#Write-Output "filename: " $filename

# Print response
if(! (Test-Path $PSScriptRoot\$filename)){
    $downloadInstaller = Invoke-RestMethod -Headers $headers -Method $method -Uri $installerURL -OutFile $filename
}

return $filename
