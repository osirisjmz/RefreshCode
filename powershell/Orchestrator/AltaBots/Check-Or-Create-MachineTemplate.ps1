param(
    [string]$MachineTemplateName,
    [string]$TenantLogicalName,
    [string]$AccountLogicalName,
    [string]$ClientId,
    [string]$ClientSecret,
    [string]$OutputLogPath
)

# Paso 1: Obtener Token de Autenticacion
$authBody = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "OR.Machines"
}
$authResponse = Invoke-RestMethod -Method Post -Uri "https://cloud.uipath.com/identity_/connect/token" -Body $authBody
$token = $authResponse.access_token

# Paso 2: Verificar si existe el Machine Template
$headers = @{ Authorization = "Bearer $token" }
$baseUrl = "https://cloud.uipath.com/$AccountLogicalName/$TenantLogicalName/odata"

$existingTemplates = Invoke-RestMethod -Uri "$baseUrl/MachineTemplates" -Headers $headers
$match = $existingTemplates.value | Where-Object { $_.Name -eq $MachineTemplateName }

if ($match) {
    $msg = "Machine Template '$MachineTemplateName' ya existe con ID: $($match.Id)"
    Add-Content -Path $OutputLogPath -Value $msg
    Write-Output $msg
    return @{
        Id = $match.Id
        Status = "Exists"
    }
}

# Paso 3: Crear nuevo Machine Template
$body = @{
    Name = $MachineTemplateName
    Type = "Standard"
}
$jsonBody = $body | ConvertTo-Json
$newTemplate = Invoke-RestMethod -Uri "$baseUrl/MachineTemplates" -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json"

$msg = "Machine Template '$MachineTemplateName' creado con ID: $($newTemplate.Id)"
Add-Content -Path $OutputLogPath -Value $msg
Write-Output $msg

return @{
    Id = $newTemplate.Id
    Status = "Created"
}
