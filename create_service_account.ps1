Param(
    [parameter()][ValidateNotNullOrEmpty()][String]$MID_NAME=$(throw "MID_NAME is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][String]$MID_USERNAME=$(throw "MID_USERNAME is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][String]$MID_PASSWORD=$(throw "MID_PASSWORD is a mandatory parameter, please provide a value."),
    [parameter()][ValidateNotNullOrEmpty()][String]$INSTANCE_URL=$(throw "INSTANCE_URL is a mandatory parameter, please provide a value.")
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
$uri = $INSTANCE_URL + "/api/1234/mid_server_installer/validateMidServer?mid_server_name=${MID_NAME}"

# Specify HTTP method
$method = "POST"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

# Send HTTP request
$validateMidServer = (Invoke-RestMethod -Headers $headers -Method $method -Uri $uri).result
return $validateMidServer
