# === CONFIGURACION ===
$token    = "rt_633825D8E9741D8838A68D7BD854D753377DF46008F59CEF01DAD895925BB399-1"
$account  = "hexawyeciivv"
$tenant   = "DefaultTenant"
$folderId = 852842  # ID del folder (X-UIPATH-OrganizationUnitId)

# === LOG ===
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "C:\Users\Ocyriz\Documents\powershells\orchestrator\AltaRobots\GetRobots_log_robots_$timestamp.txt"

# Crear archivo de log
New-Item -Path $logPath -ItemType File -Force | Out-Null

# Funcion de log
function Write-Log {
    param([string]$message)
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$now - $message"
    Write-Output $line
    Add-Content -Path $logPath -Value $line
}

Write-Log "Inicio de ejecucion - Consulta de Robots"

# === ENDPOINT ===
$uri = "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/Robots?`$count=true"

# === CABECERAS ===
$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/json"
    "X-UIPATH-OrganizationUnitId" = $folderId
}

# === CONSULTA ===
try {
    Write-Log "[INICIO] Llamada a /odata/Robots"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
    Write-Log "[OK] Total de robots encontrados: $($response.'@odata.count')"

    foreach ($robot in $response.value) {
        $info = "ID: $($robot.Id), Nombre: $($robot.Name), Tipo: $($robot.Type), Maquina: $($robot.MachineName)"
        Write-Log $info
    }

    Write-Log "[FIN] Consulta de /odata/Robots"

} catch {
    Write-Log "[ERROR] Fallo en consulta de Robots: $($_.Exception.Message)"
}
