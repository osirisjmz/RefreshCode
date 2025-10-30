# MainSetup.ps1

# Ruta de los scripts
$basePath = "C:\Scripts\UiPath" # Modifica si tus scripts estan en otro lado
$logPath = "$basePath\log_creacion_robots.txt"
$excelPath = "$basePath\robots.xlsx"

# Cargar modulo para leer Excel
Import-Module ImportExcel

# Leer el archivo Excel
$robots = Import-Excel -Path $excelPath

# Recorrer cada fila
foreach ($row in $robots) {
    $machineTemplate = $row.MachineTemplateName
    $robotName       = $row.RobotName
    $domainUser      = $row.DomainUser
    $password        = $row.Password
    $tenant          = $row.TenantLogicalName
    $account         = $row.AccountLogicalName
    $clientId        = $row.ClientId
    $clientSecret    = $row.ClientSecret
    $folderName      = "Shared"  # O puedes poner otro folder si deseas

    Write-Output "`nProcesando robot: $robotName" | Tee-Object -Append -FilePath $logPath

    # Ejecutar script para plantilla de maquina
    $machineResult = & "$basePath\Check-Or-Create-MachineTemplate.ps1" `
        -MachineTemplateName $machineTemplate `
        -TenantLogicalName $tenant `
        -AccountLogicalName $account `
        -ClientId $clientId `
        -ClientSecret $clientSecret `
        -OutputLogPath $logPath

    $machineId = $machineResult.Id

    # Ejecutar script para crear robot
    $robotResult = & "$basePath\Check-Or-Create-RobotAccount.ps1" `
        -RobotName $robotName `
        -DomainUser $domainUser `
        -Password $password `
        -MachineTemplateName $machineTemplate `
        -TenantLogicalName $tenant `
        -AccountLogicalName $account `
        -ClientId $clientId `
        -ClientSecret $clientSecret `
        -OutputLogPath $logPath

    # Obtener ID del robot si se creo
    $robotData = Invoke-RestMethod -Uri "https://cloud.uipath.com/$account/$tenant/odata/Robots?`$filter=Name eq '$robotName'" -Headers @{ Authorization = "Bearer $((Invoke-RestMethod -Method Post -Uri 'https://cloud.uipath.com/identity_/connect/token' -Body @{grant_type='client_credentials'; client_id=$clientId; client_secret=$clientSecret; scope='OR.Robots'}).access_token)" }
    $robotId = $robotData.value[0].Id

    # Ejecutar script para folder
    & "$basePath\Check-Or-Create-Folder.ps1" `
        -FolderName $folderName `
        -RobotId $robotId `
        -MachineId $machineId `
        -TenantLogicalName $tenant `
        -AccountLogicalName $account `
        -ClientId $clientId `
        -ClientSecret $clientSecret `
        -OutputLogPath $logPath
}
