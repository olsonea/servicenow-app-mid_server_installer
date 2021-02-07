Param (
  [parameter()][ValidateNotNullOrEmpty()][String]$MID_NAME=$(throw "MID_NAME is a mandatory parameter, please provide a value."),
  [parameter()][ValidateNotNullOrEmpty()][String]$LOG_NAME
)

<# check 64 bit keys #>
$installedProductCode = "";

$64bit = Get-ItemProperty "HKLM:SOFTWARE\Manufacturer\ServiceNow\MID_Server\*\" -ErrorAction SilentlyContinue | Select "MID Name", "ProductCode";
foreach ($instance in $64bit) {
    if($MID_NAME -eq $instance.'MID Name') {
        $installedProductCode = $instance.ProductCode;
        break;
    }
}
<# check 32 bit keys if we didn't find MID name in 64 bit keys #>
if (-not $installedProductCode) {
    $32bit = Get-ItemProperty "HKLM:SOFTWARE\WOW6432Node\Manufacturer\ServiceNow\MID_Server\*\" -ErrorAction SilentlyContinue | Select "MID Name", "ProductCode";

    foreach ($instance in $32bit) {
        if($MID_NAME -eq $instance.'MID Name') {
            $installedProductCode = $instance.ProductCode;
            break;
        }
    }
}

if(-not $installedProductCode) {
    throw "MID Server was not installed through the MSI installer, or registry key was deleted.";
}

$uninstallCmd = "MsiExec.exe /X" + $installedProductCode + " /qn";

if($LOG_NAME) {
    $uninstallCmd += " /l*v `"" + $LOG_NAME + "`"";
}
cmd.exe /c $uninstallCmd;