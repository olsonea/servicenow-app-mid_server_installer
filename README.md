# servicenow-app-mid_server_installer
ServiceNow global app to provide a RESTful way to obtain the path for latest mid server installer.

## Default URL
GET /api/1234/mid_server_installer

## Headers
| name | value |
|------|-------|
|Accept|application/json|
|Content-Type|application/json|

## Query Parameters
| name | value |
|------|-------|
|packageName|mid,mid-windows-installer|
|operatingSystem|windows,linux,osx|
|architecture|x86-32,x86-64|

## Powershell download_and_install.ps1 example
.\download_and_install.ps1 -INSTALL_LOCATION "C:\glide" -INSTANCE_URL "https://instance.service-now.com" -MID_USERNAME 'integration.mid' -MID_PASSWORD 'super_secret_pa$$w0rd' -MID_NAME 'MID_01' -SERVICE_ACCOUNT_NAME 'snow_mid_svc' -SERVICE_ACCOUNT_PASSWORD 'super_secret_pa$$w0rd' -LOG_NAME "install.log" -START_MID