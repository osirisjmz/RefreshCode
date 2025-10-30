# Ruta del archivo Excel
$excelPath = "Data\Input\HistorialCorreos.xlsx"

# Cargar Excel
$excel = New-Object -ComObject Excel.Application
$workbook = $excel.Workbooks.Open((Resolve-Path $excelPath))
$worksheet = $workbook.Sheets.Item("Coleccion")
$usedRange = $worksheet.UsedRange
$rows = $usedRange.Rows.Count
$cols = $usedRange.Columns.Count

# Encabezados
$headers = @()
for ($c = 1; $c -le $cols; $c++) {
    $headers += $usedRange.Cells.Item(1, $c).Text
}

# Iterar filas
for ($r = 2; $r -le $rows; $r++) {
    $rowData = @{}
    for ($c = 1; $c -le $cols; $c++) {
        $key = $headers[$c - 1]
        $value = $usedRange.Cells.Item($r, $c).Text
        $rowData[$key] = $value
    }

    # Crear JSON
    $reference = $rowData["Remitente"]
    $jsonBody = @{
        itemData = @{
            Name = "QueueTesting_NonUnique"
            Priority = "High"
            SpecificContent = $rowData
            Reference = $reference
            Source = "Manual"
        }
    } | ConvertTo-Json -Depth 5

    # Enviar petición al Orchestrator
    Invoke-RestMethod -Uri "https://hexawyeciivv/odata/Queues/UiPathODataSvc.AddQueueItem" `
                      -Method POST `
                      -Body $jsonBody `
                      -ContentType "application/json" `
                      -Headers @{ Authorization = "Bearer https://cloud.uipath.com/identity_/connect/token" }
}

# Cerrar Excel
$workbook.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
Remove-Item -Path $excelPath
