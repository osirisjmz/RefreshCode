Connect-PnPOnline -Url "https://universidadciudadana.sharepoint.com/sites/Osirisjmz" -Interactive

$remotePath = "Shared Documents/ReFramework/Data/Config.xlsx"
$localPath = "$env:TEMP\Config.xlsx"

Get-PnPFile -Url $remotePath -Path $env:TEMP -FileName "Config.xlsx" -AsFile -Force

$excelData = Import-Excel -Path $localPath

$config = @{}
foreach ($row in $excelData) {
    if ($row.Name -and $row.Data) {
        $config[$row.Name] = $row.Data
    }
}

$config

