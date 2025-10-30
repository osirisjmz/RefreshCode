# Ruta base de los scripts y Excel
$basePath = "C:\Users\Ocyriz\Documents\powershells\orchestrator\AltaRobots"
$excelPath = "$basePath\robots.xlsx"
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$logPath = "$basePath\log_creacion_robots_$timestamp.txt"

# Crear nuevo log
New-Item -Path $logPath -ItemType File -Force | Out-Null

# Funcion unificada para escribir en log y consola
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Output $logEntry
    Add-Content -Path $logPath -Value $logEntry
}

Write-Log "Inicio de ejecucion"

# Cargar modulo Excel
Import-Module ImportExcel -ErrorAction Stop

try {
    Write-Log "[INICIO] Lectura del archivo de configuracion Excel: robots.xlsx"
    $robots = Import-Excel -Path $excelPath

    foreach ($row in $robots) {
        $machineTemplate = $row.MachineTemplateName
        $robotName       = $row.RobotName
        $domainUser      = $row.DomainUser
        $password        = $row.Password
        $tenant          = $row.TenantLogicalName
        $account         = $row.AccountLogicalName
        $clientId        = $row.ClientId
        $clientSecret    = $row.ClientSecret
        $folderName      = "Shared"

        Write-Log "  Variables cargadas:"
        Write-Log "    MachineTemplateName = $machineTemplate"
        Write-Log "    RobotName           = $robotName"
        Write-Log "    DomainUser          = $domainUser"
        Write-Log "    TenantLogicalName   = $tenant"
        Write-Log "    AccountLogicalName  = $account"
        Write-Log "    ClientId            = $clientId"
        Write-Log "    ClientSecret        = $clientSecret"
        Write-Log "[FIN] Lectura del archivo Excel"

        if ([string]::IsNullOrWhiteSpace($clientId) -or [string]::IsNullOrWhiteSpace($clientSecret)) {
            Write-Log "[ERROR] ClientId o ClientSecret no definidos. Se omite el robot: $robotName"
            continue
        }

        Write-Log "--- Procesando robot: $robotName ---"

        try {
            Write-Log "[INICIO] Invocando Check-Or-Create-MachineTemplate.ps1"
            $machineResult = & "$basePath\Check-Or-Create-MachineTemplate.ps1" `
                -MachineTemplateName $machineTemplate `
                -TenantLogicalName $tenant `
                -AccountLogicalName $account `
                -ClientId $clientId `
                -ClientSecret $clientSecret `
                -OutputLogPath $logPath
            $machineId = $machineResult.Id
            Write-Log "[FIN] Check-Or-Create-MachineTemplate.ps1"
        } catch {
            Write-Log "[ERROR] Machine Template '${machineTemplate}': $($_.Exception.Message)"
            Write-Log "[FIN] Check-Or-Create-MachineTemplate.ps1"
            continue
        }

        try {
            Write-Log "[INICIO] Invocando Check-Or-Create-RobotAccount.ps1"
            & "$basePath\Check-Or-Create-RobotAccount.ps1" `
                -RobotName $robotName `
                -DomainUser $domainUser `
                -Password $password `
                -MachineTemplateName $machineTemplate `
                -TenantLogicalName $tenant `
                -AccountLogicalName $account `
                -ClientId $clientId `
                -ClientSecret $clientSecret `
                -OutputLogPath $logPath
            Write-Log "[FIN] Check-Or-Create-RobotAccount.ps1"
        } catch {
            Write-Log "[ERROR] Robot '${robotName}': $($_.Exception.Message)"
            Write-Log "[FIN] Check-Or-Create-RobotAccount.ps1"
            continue
        }

        try {
            Write-Log "[INICIO] Obteniendo ID del robot '${robotName}'"
            $token = (Invoke-RestMethod -Method Post -Uri 'https://cloud.uipath.com/identity_/connect/token' -Body @{
                grant_type    = 'client_credentials'
                client_id     = $clientId
                client_secret = $clientSecret
                scope         = 'OR.Robots'
            }).access_token

            $robotData = Invoke-RestMethod -Uri "https://cloud.uipath.com/$account/$tenant/odata/Robots?`$filter=Name eq '$robotName'" -Headers @{ Authorization = "Bearer $token" }
            $robotId = $robotData.value[0].Id
            Write-Log "[FIN] Obtenido RobotId: $robotId"
        } catch {
            Write-Log "[ERROR] Obtener ID del robot '${robotName}': $($_.Exception.Message)"
            continue
        }

        try {
            Write-Log "[INICIO] Invocando Check-Or-Create-Folder.ps1"
            & "$basePath\Check-Or-Create-Folder.ps1" `
                -FolderName $folderName `
                -RobotId $robotId `
                -MachineId $machineId `
                -TenantLogicalName $tenant `
                -AccountLogicalName $account `
                -ClientId $clientId `
                -ClientSecret $clientSecret `
                -OutputLogPath $logPath
            Write-Log "[FIN] Check-Or-Create-Folder.ps1"
        } catch {
            Write-Log "[ERROR] Folder '${folderName}' para ${robotName}: $($_.Exception.Message)"
            Write-Log "[FIN] Check-Or-Create-Folder.ps1"
            continue
        }

        Write-Log "[FIN] Procesamiento de ${robotName}`n"
    }

} catch {
    Write-Log "[ERROR] Falla general en ejecucion: $($_.Exception.Message)"
}
