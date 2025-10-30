# CONFIGURACIÓN
$mainExcelPath = "C:\Users\Ocyriz\Documents\UiPath\dispatcher\Data\Input\ArchivoPrincipal.xlsx"
$processedFolder = "C:\Users\Ocyriz\Documents\UiPath\dispatcher\Data\Processed"
$logPath = "C:\Users\Ocyriz\Documents\UiPath\dispatcher\Data\log_universal_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
$folderId = "852842"
$token = "rt_07467D7B069F3544272AD1ABE5F6914A50C10333694124B617657753131F4C34-1"

if (-not (Test-Path -Path $processedFolder)) {
    New-Item -Path $processedFolder -ItemType Directory | Out-Null
}

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Output $logEntry
    Add-Content -Path $logPath -Value $logEntry
}

New-Item -Path $logPath -ItemType File -Force | Out-Null
Write-Log "Inicio de Ejecución"

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$mainWorkbook = $excel.Workbooks.Open($mainExcelPath)
$mainSheet = $mainWorkbook.Sheets.Item(1)
$usedRange = $mainSheet.UsedRange
$totalRows = $usedRange.Rows.Count

for ($r = 2; $r -le $totalRows; $r++) {
    $status = $usedRange.Cells.Item($r, 3).Text
    $queueName = $usedRange.Cells.Item($r, 4).Text  # Columna Queue
    if ([string]::IsNullOrWhiteSpace($status) -and -not [string]::IsNullOrWhiteSpace($queueName)) {
        $pathArchivo = $usedRange.Cells.Item($r, 2).Text

        if (-not (Test-Path $pathArchivo)) {
            Write-Log "Ruta no encontrada: $pathArchivo"
            continue
        }

        $usedRange.Cells.Item($r, 3).Value2 = "Procesando"
        Write-Log "Procesando archivo: $pathArchivo en Queue: $queueName"

        $dataWb = $excel.Workbooks.Open($pathArchivo)
        $dataSheet = $dataWb.Sheets.Item(1)
        $dataRange = $dataSheet.UsedRange
        $dataRows = $dataRange.Rows.Count
        $dataCols = $dataRange.Columns.Count

        if ($dataRows -le 1) {
            Write-Log "Archivo sin datos: $pathArchivo"
            $dataWb.Close($false)
            continue
        }

        # Leer encabezados
        $headers = @()
        for ($c = 1; $c -le $dataCols; $c++) {
            $headers += $dataRange.Cells.Item(1, $c).Text
        }

        # Procesar filas
        for ($dr = 2; $dr -le $dataRows; $dr++) {
            $pairs = @()
            foreach ($col in $headers) {
                $value = $dataRange.Cells.Item($dr, ($headers.IndexOf($col) + 1)).Text
                $escapedValue = $value -replace '"', '\"'
                $pairs += '"' + $col + '":"' + $escapedValue + '"'
            }

            $jsonContent = '{' + ($pairs -join ",") + '}'

            $referenceRaw = $dataRange.Cells.Item($dr, ($headers.IndexOf("Remitente") + 1)).Text
            $reference = $referenceRaw -replace '"', '\"' -replace '<', '' -replace '>', ''

            if ([string]::IsNullOrWhiteSpace($reference)) {
                Write-Log "Fila $dr omitida por Remitente vacío"
                continue
            }

            $jsonBody = @"
{
  "itemData": {
    "Name": "$queueName",
    "Priority": "High",
    "SpecificContent": $jsonContent,
    "Reference": "$reference",
    "Source": "Manual"
  }
}
"@

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
                Write-Log "Item $reference agregado en $queueName"
            } catch {
                Write-Log "Error en $reference - $($_.Exception.Message)"
            }
        }

        $dataWb.Close($false)
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($dataRange) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($dataSheet) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($dataWb) | Out-Null

        try {
            $fileName = Split-Path $pathArchivo -Leaf
            Move-Item -Path $pathArchivo -Destination (Join-Path $processedFolder $fileName) -Force
            Write-Log "Archivo movido: $fileName"
        } catch {
            Write-Log "No se pudo mover el archivo $pathArchivo - $($_.Exception.Message)"
        }

       $usedRange.Cells.Item($r, 3).Value2 = "Procesado"
       Write-Log "Archivo procesado: $pathArchivo"
       $mainWorkbook.Save()  # Guardar inmediatamente después de actualizar

    }
}

$mainWorkbook.Save()
$mainWorkbook.Close($false)
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($usedRange) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($mainSheet) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($mainWorkbook) | Out-Null
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null

[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Log "Fin de la Ejecución"
