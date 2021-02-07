# Eg. User name="admin", Password="admin" for this code sample.
$user = "integration.mid"
$pass = "integration.mid"

$instance = 'snow.heathcraft.com'
$name = 'mid-windows-installer'
$operatingSystem = 'windows'
$architecture = 'x86-64'

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
#$uri = "https://" + $instance + "/api/1234/mid_server_installer?name=" + $name + "&operatingSystem=" + $operatingSystem + "&architecture=" + $architecture
$uri = "https://" + $instance + "/api/1234/mid_server_installer"

# Specify HTTP method
$method = "get"

# Send HTTP request
$installerURL = (Invoke-RestMethod -Headers $headers -Method $method -Uri $uri).result
$filename = $installerURL.Substring($installerURL.LastIndexOf("/") + 1)

# Print response
$downloadInstaller = Invoke-RestMethod -Headers $headers -Method $method -Uri $installerURL -OutFile $filename
