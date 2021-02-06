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