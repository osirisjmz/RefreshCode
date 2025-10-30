
# === CONFIGURACION ===
$token       = "rt_02C37036875875BEAED966BEF01B0F7F06C5C8E3C58A70169ABC55D11BCAA043-1"
$account     = "hexawyeciivv"
$tenant      = "DefaultTenant"
$folderId    = 852842

# === DATOS DEL ROBOT A CREAR ===
$robotName   = "Robot03"
$username    = "Users\\Ocyriz"
$password    = "MiPassword123"
$machineId   = 4964513
$machineName = "IBM_Machine"

# === LOG ===
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "C:\Users\Ocyriz\Documents\powershells\orchestrator\AltaRobots\CreateRobot_log_20250414_093036.txt"
New-Item -Path $logPath -ItemType File -Force | Out-Null

function Write-Log {
    param([string]$message)
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$now - $message"
    Write-Output $line
    Add-Content -Path $logPath -Value $line
}

Write-Log "Inicio de ejecucion - Create-Robot.ps1"
Write-Log "Validando tipo de MachineId: $machineId"
Write-Log "Tipo de MachineId: $($machineId.GetType().Name)"

# === CABECERAS ===
$headers = @{
    Authorization                  = "Bearer $token"
    Accept                         = "application/json"
    "Content-Type"                 = "application/json"
    "X-UIPATH-OrganizationUnitId" = $folderId
}

# === CUERPO DEL ROBOT (MINIMO FUNCIONAL) ===
$robotBody = @{ 
    Name           = $robotName
    Username       = $username
    Password       = $password
    MachineId      = $machineId
    MachineName    = $machineName
    Type           = "Unattended"
    HostingType    = "Standard"
    ProvisionType  = "Manual"
    CredentialType = "Windows"
    Enabled        = $true
    Description    = "Robot creado desde PowerShell"
} | ConvertTo-Json -Depth 10

# === ENDPOINT ===
$uri = "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/Robots"

# === LLAMADA ===
try {
    Write-Log "[INICIO] Creando robot '$robotName'"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $robotBody
    Write-Log "[OK] Robot creado exitosamente con ID: $($response.Id)"
    Write-Log "[FIN] Creacion de robot"
} catch {
    Write-Log "[ERROR] Error al crear robot '$robotName': $($_.Exception.Message)"
}
