
# CONFIGURACIÓN
$logPath = "C:\Users\Ocyriz\Documents\UiPath\dispatcher\Data\log_testapi_Log_$timestamp.txt"
$token = "rt_44A2B8AC7189E9013D0AA172D932E3677ECE1050FF624905695D1DF0CF77551C-1"#"rt_6BD183BB5998241E91F0D11D817B3C61CBDEDBC5541872AA92FA698C352DDE98-1"
$folderId = "852842"

# FUNCION LOG
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Output $logEntry
    Add-Content -Path $logPath -Value $logEntry
}

New-Item -Path $logPath -ItemType File -Force | Out-Null
Write-Log "Test de conectividad a APIs de UiPath iniciado."

# PRUEBA DE FOLDERS
try {
    Write-Log "Probando /odata/Queues..."
    $folders = Invoke-RestMethod `
        -Uri "https://cloud.uipath.com/hexawyeciivv/DefaultTenant/odata/Folders" #https://cloud.uipath.com/hexawyeciivv/DefaultTenant/odata/Folders`
        -Headers @{
            Authorization = "Bearer $token"
            "X-UIPATH-TenantName" = "DefaultTenant"
        } `
        -Method GET
    Write-Log "Conexion exitosa a /odata/Queues. Total encontrados: $($folders.value.Count)"
} catch {
    Write-Log "Error conectando a /odata/Folders: $($_.Exception.Message)"
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        Write-Log " Detalle: $($_.ErrorDetails.Message)"
    }
}

# PRUEBA DE QUEUES
try {
    Write-Log "Probando /odata/Queues..."
    $queues = Invoke-RestMethod `
        -Uri "https://cloud.uipath.com/hexawyeciivv/DefaultTenant/odata/Queues" `
        -Headers @{
            Authorization = "Bearer $token"
            "X-UIPATH-OrganizationUnitId" = "$folderId"
        } `
        -Method GET
    Write-Log "Conexion exitosa a /odata/Queues. Total encontrados: $($queues.value.Count)"
} catch {
    Write-Log "Error conectando a /odata/Queues: $($_.Exception.Message)"
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        Write-Log "Detalle: $($_.ErrorDetails.Message)"
    }
}

# PRUEBA DE GET ORGANIZATION UNITS
try {
    Write-Log "Probando /odata/Users..."
    $users = Invoke-RestMethod `
        -Uri "https://cloud.uipath.com/hexawyeciivv/DefaultTenant/odata/Users" `
        -Headers @{
            Authorization = "Bearer $token"
            "X-UIPATH-OrganizationUnitId" = "$folderId"
        } `
        -Method GET
    Write-Log "Conexion exitosa a /odata/Users. Total encontrados: $($users.value.Count)"
} catch {
    Write-Log "❌ Error conectando a /odata/Users: $($_.Exception.Message)"
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        Write-Log "Detalle: $($_.ErrorDetails.Message)"
    }
}

Write-Log "Test de APIs finalizado."
