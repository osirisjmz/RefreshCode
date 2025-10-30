Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force -AllowClobber
# Paso 0: Instalar los módulos necesarios (solo la primera vez)
# Ejecuta estas líneas si aún no tienes los módulos instalados
# Install-Module PnP.PowerShell -Scope CurrentUser -Force
# Install-Module ImportExcel -Scope CurrentUser -Force

# Paso 1: Conectar a SharePoint Online
Connect-PnPOnline -Url "https://universidadciudadana.sharepoint.com/sites/Osirisjmz" -Interactive

# Paso 2: Definir ruta remota y ruta local temporal
$remotePath = "Shared Documents/ReFramework/Data/Config.xlsx"
$localPath = "$env:TEMP\Config.xlsx"

# Paso 3: Descargar archivo desde SharePoint
Get-PnPFile -Url $remotePath -Path $env:TEMP -FileName "Config.xlsx" -AsFile -Force

# Paso 4: Leer el archivo Excel
$excelData = Import-Excel -Path $localPath

# Paso 5: Extraer columnas Name y Data en una variable tipo hashtable
$config = @{}
foreach ($row in $excelData) {
    if ($row.Name -and $row.Data) {
        $config[$row.Name] = $row.Data
    }
}

# Paso 6: Mostrar resultados (puedes comentar esta línea si no lo necesitas)
$config