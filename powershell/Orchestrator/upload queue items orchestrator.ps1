
# Ruta del archivo Excel y de log
$excelPath = "C:\Users\Ocyriz\Documents\UiPath\dispatcher\Data\Input\QueueItems_50Personas.xlsx"
$logPath = "C:\Users\Ocyriz\Documents\UiPath\dispatcher\Data\log_universal_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
$folderId = "852842"

# Funcion para registrar en log y consola
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Output $logEntry
    Add-Content -Path $logPath -Value $logEntry
}

New-Item -Path $logPath -ItemType File -Force | Out-Null
Write-Log "Nueva ejecucion iniciada."

Write-Log "Leyendo archivo Excel"

# Cargar Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Open($excelPath)
$worksheet = $workbook.Sheets.Item("Coleccion")
$usedRange = $worksheet.UsedRange
$rows = $usedRange.Rows.Count
$cols = $usedRange.Columns.Count

# Leer encabezados
$headers = @()
for ($c = 1; $c -le $cols; $c++) {
    $headers += $usedRange.Cells.Item(1, $c).Text
}

Write-Log "Total filas detectadas: $($rows - 1)"

# Token de acceso valido
$token = "rt_07467D7B069F3544272AD1ABE5F6914A50C10333694124B617657753131F4C34-1"

for ($r = 2; $r -le $rows; $r++) {
    $rowData = @{}
    for ($c = 1; $c -le $cols; $c++) {
        $key = $headers[$c - 1]
        $value = $usedRange.Cells.Item($r, $c).Text
        $rowData[$key] = $value
    }

    $reference = $rowData["Remitente"]
    Write-Log "Procesando fila $($r - 1): $reference"

    $payload = @{
        itemData = @{
            Name = "QueueTesting_NonUnique"
            Priority = "High"
            SpecificContent = $rowData
            Reference = $reference
            Source = "Manual"
        }
    }

    $jsonBody = $payload | ConvertTo-Json -Depth 10
    Write-Log "Payload: $jsonBody"

    try {
        Invoke-RestMethod `
            -Uri "https://cloud.uipath.com/hexawyeciivv/DefaultTenant/odata/Queues/UiPathODataSvc.AddQueueItem" `
            -Method POST `
            -Body $jsonBody `
            -ContentType "application/json" `
            -Headers @{
                Authorization = "Bearer $token"
                "X-UIPATH-OrganizationUnitId" = "$folderId"
            }
        Write-Log "Exito en $reference"
    } catch {
        Write-Log "Error con $reference - $($_.Exception.Message)"
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            Write-Log " Detalle: $($_.ErrorDetails.Message)"
        }
    }
}

# Cerrar Excel
$workbook.Close($false)
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($usedRange) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($worksheet) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
Start-Sleep -Seconds 3

# Intentar borrar Excel
$retry = 0
do {
    try {
        Remove-Item -Path $excelPath -Force -ErrorAction Stop
        Write-Log "Archivo Excel eliminado"
        $deleted = $true
    } catch {
        Write-Log " No se pudo borrar (intento $($retry + 1)). Puede estar en uso."
        Start-Sleep -Seconds 2
        $deleted = $false
        $retry++
    }
} until ($deleted -or $retry -ge 3)

if (-not $deleted) {
    Write-Log "Archivo no se pudo eliminar tras varios intentos"
}
