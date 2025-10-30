# === CONFIGURACION ===
$token    = "rt_02C37036875875BEAED966BEF01B0F7F06C5C8E3C58A70169ABC55D11BCAA043-1"
$account  = "hexawyeciivv"
$tenant   = "DefaultTenant"
$folderId = 852842

# === LOG ===
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "C:\Users\Ocyriz\Documents\powershells\orchestrator\AltaRobots\GetUsers_log_$timestamp.txt"
New-Item -Path $logPath -ItemType File -Force | Out-Null

function Write-Log {
    param([string]$message)
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$now - $message"
    Write-Output $line
    Add-Content -Path $logPath -Value $line
}

Write-Log "Inicio de ejecucion - Consulta de Usuarios"

# === ENDPOINT ===
$uri = "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/Users?`$count=true"

# === CABECERAS ===
$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/json"
    "X-UIPATH-OrganizationUnitId" = $folderId
}

# === CONSULTA ===
try {
    Write-Log "[INICIO] Llamada a /odata/Users"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
    Write-Log "[OK] Total de usuarios encontrados: $($response.'@odata.count')"

    foreach ($user in $response.value) {
        $info = "ID: $($user.Id), Nombre: $($user.Name), Email: $($user.Email)"
        Write-Log $info
    }

    Write-Log "[FIN] Consulta de /odata/Users"
} catch {
    Write-Log "[ERROR] Fallo en consulta de Usuarios: $($_.Exception.Message)"
}
