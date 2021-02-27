$gitZipURI = 'https://github.com/olsonea/servicenow-app-mid_server_installer/archive/sn_instances/servicenow-631ecd992d022010076dc1c42939613a.zip'
$gitZipFile = Split-Path $gitZipURI -leaf
$outfile = '{0}\Downloads\{1}' -f $home, $gitZipFile

Invoke-WebRequest -Uri $gitZipURI -OutFile $outfile