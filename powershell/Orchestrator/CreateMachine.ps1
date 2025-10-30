# === CONFIGURACION ===
$token    = "rt_02C37036875875BEAED966BEF01B0F7F06C5C8E3C58A70169ABC55D11BCAA043-1"
$account  = "hexawyeciivv"
$tenant   = "DefaultTenant"

# === LOG ===
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "C:\Users\Ocyriz\Documents\powershells\orchestrator\AltaRobots\CreateMachine_log_$timestamp.txt"

New-Item -Path $logPath -ItemType File -Force | Out-Null
function Write-Log {
    param([string]$message)
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$now - $message"
    Write-Output $line
    Add-Content -Path $logPath -Value $line
}

Write-Log "Inicio de ejecucion - Create-Machine.ps1"

# === DATOS DE LA MACHINE ===
$machineName   = "Osiris"
$description   = "Creada desde PowerShell"
$scope         = "Default"

# === BODY LIMPIO ===
$robotBody = @{
    Name          = $robotName
    Username      = $username
    Password      = $password
    MachineId     = $machineId
    MachineName   = $machineName
    Type          = "Unattended"
    HostingType   = "Standard"
    ProvisionType = "Manual"
    CredentialType = "Windows"
    Enabled       = $true
    Description   = "Prueba mínima desde PowerShell"
} | ConvertTo-Json -Depth 10


# === CABECERAS ===
$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/json"
    "Content-Type" = "application/json"
}

# === ENDPOINT ===
$uri = "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/Machines"

# === ENVIO ===
try {
    Write-Log "[INICIO] Creacion de Machine '$machineName'"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
    Write-Log "[OK] Machine creada con ID: $($response.Id)"
    Write-Log "[FIN] Creacion de Machine"
} catch {
    Write-Log "[ERROR] Error al crear Machine: $($_.Exception.Message)"
}
