# === CONFIGURACION ===
$token    = "rt_02C37036875875BEAED966BEF01B0F7F06C5C8E3C58A70169ABC55D11BCAA043-1"
$account  = "hexawyeciivv"
$tenant   = "DefaultTenant"

# === LOG ===
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "C:\Users\Ocyriz\Documents\powershells\orchestrator\AltaRobots\GetMachineTemplates_Log_$timestamp.txt"

New-Item -Path $logPath -ItemType File -Force | Out-Null

function Write-Log {
    param([string]$message)
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$now - $message"
    Write-Output $line
    Add-Content -Path $logPath -Value $line
}

Write-Log "Inicio de ejecucion - Get-MachineTemplates.ps1"

# === ENDPOINT ===
$uri = "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/MachineTemplates"

# === CABECERAS ===
$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/json"
}

# === CONSULTA ===
try {
    Write-Log "[INICIO] Llamada a /odata/MachineTemplates"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

    $total = $response.value.Count
    Write-Log "[OK] Total de plantillas de maquina encontradas: $total"

    foreach ($machine in $response.value) {
        $line = "ID: $($machine.Id), Nombre: $($machine.Name), Tipo: $($machine.Type)"
        Write-Log $line
    }

    Write-Log "[FIN] Consulta de MachineTemplates"

} catch {
    Write-Log "[ERROR] Fallo en consulta de MachineTemplates: $($_.Exception.Message)"
}
