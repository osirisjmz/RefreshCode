param()

# URL del archivo Excel en SharePoint (asegúrate de usar ?download=1 para forzar descarga directa)
$sharePointUrl = "https://universidadciudadana.sharepoint.com/sites/Osirisjmz/Shared%20Documents/ReFramework/Data/Config.xlsx?download=1"

# Ruta temporal donde se guardará el archivo descargado
$tempPath = Join-Path $env:TEMP "Config.xlsx"

# Descargar el archivo desde SharePoint
try {
    Invoke-WebRequest -Uri $sharePointUrl -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
    Write-Output "Archivo descargado exitosamente: $tempPath"
} catch {
    Write-Error "Error al descargar el archivo desde SharePoint: $_"
    exit 1
}

# Verificar si el archivo descargado es realmente un archivo Excel y no una página HTML
$firstLine = Get-Content -Path $tempPath -TotalCount 1
if ($firstLine -match "<!DOCTYPE html>" -or $firstLine -match "<html") {
    Write-Error "El archivo descargado no es un archivo Excel válido. Parece ser una página HTML (posiblemente requiere autenticación)."
    Remove-Item $tempPath -Force
    exit 1
}

# Crear una instancia de Excel en segundo plano
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

# Intentar abrir el archivo Excel y acceder a la hoja llamada "Assets"
try {
    $workbook = $excel.Workbooks.Open($tempPath, $null, $true)  # Abrir en modo solo lectura
    $sheet = $workbook.Sheets.Item("Assets")
    Write-Output "Hoja 'Assets' abierta correctamente."
} catch {
    Write-Error "Error al abrir el archivo o la hoja 'Assets': $_"
    $excel.Quit()
    Remove-Item $tempPath -Force
    exit 1
}

# Inicializar un diccionario vacío (Hashtable) para almacenar las claves y valores
$Config = @{}

# Leer hasta 100 filas desde la hoja "Assets"
for ($row = 2; $row -le 100; $row++) {
    $key = $sheet.Cells.Item($row, 1).Text
    $value = $sheet.Cells.Item($row, 2).Text

    # Si la clave no está vacía, agregarla al diccionario
    if (![string]::IsNullOrWhiteSpace($key)) {
        $Config[$key] = $value
    } else {
        # Si la fila está vacía, terminar el bucle
        break
    }
}

# Cerrar el archivo Excel y liberar recursos COM
$workbook.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# Eliminar el archivo temporal descargado
Remove-Item $tempPath -Force

# Mostrar el contenido del diccionario (opcional para depuración)
Write-Output "Diccionario cargado:"
$Config

# Convertir el diccionario a JSON comprimido para su uso en Power Automate Desktop
$Config | ConvertTo-Json -Compress
