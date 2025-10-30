<#
. SINTAXIS
    .\Get-UipathLicenses.ps1

. DESCRIPCIÓN
    Obtiene token OAuth (client_credentials) y llama al endpoint:
    /odata/LicensesRuntime/UiPath.Server.Configuration.OData.GetLicensesRuntime(robotType='{robotType}')

    Muestra un resumen por tipo de licencia y opcionalmente itera sobre una lista de robotTypes.

. PARÁMETROS
    -ClientId, -ClientSecret, -AccountLogicalName, -TenantLogicalName
    -RobotType : por ejemplo "NonProduction", "Attended", etc. Si pasas "ALL" itera la lista predeterminada.
#>

param(
    [Parameter(Mandatory=$true)] [string] $ClientId,
    [Parameter(Mandatory=$true)] [string] $ClientSecret,
    [Parameter(Mandatory=$true)] [string] $AccountLogicalName,
    [Parameter(Mandatory=$true)] [string] $TenantLogicalName,
    [string] $RobotType = "NonProduction"
)

function Get-AuthToken {
    param($ClientId, $ClientSecret)

    $tokenUrl = "https://cloud.uipath.com/identity_/connect/token"
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "OR.License"    # o "OR.License.Read" según permisos
    }

    try {
        $resp = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
        return $resp.access_token
    } catch {
        Write-Error "Error al obtener token: $($_.Exception.Message)"
        return $null
    }
}

function Get-LicensesForRobotType {
    param($accessToken, $account, $tenant, $robotType)

    $escapedRobotType = [System.Uri]::EscapeDataString($robotType)
    $url = "https://cloud.uipath.com/$account/$tenant/odata/LicensesRuntime/UiPath.Server.Configuration.OData.GetLicensesRuntime(robotType='$escapedRobotType')"
    $headers = @{ Authorization = "Bearer $accessToken"; Accept = "application/json" }

    try {
        $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop
        return $resp
    } catch {
        Write-Error "Error al consultar LicensesRuntime para '$robotType': $($_.Exception.Message)"
        return $null
    }
}

function Summarize-Licenses {
    param($resp, $robotType)

    if (-not $resp) { return }

    # Dependiendo del esquema de respuesta, puede venir como objeto o como array en .value
    $data = $null
    if ($resp.PSObject.Properties.Name -contains 'value') { $data = $resp.value } else { $data = $resp }

    if (-not $data) {
        Write-Host "Respuesta vacía para $robotType"
        return
    }

    # Mostrar output crudo para inspección
    Write-Host "`n--- Resultado crudo para $robotType ---"
    $data | ConvertTo-Json -Depth 5
    Write-Host "-------------------------------------`n"

    # Intento de agrupar por Name/LicenseType/Status - adaptalo a los campos reales
    # Buscamos propiedades comunes (por ejemplo: LicenseType, Name, Count, Available)
    $groupField = $null
    foreach ($try in @("LicenseType","Name","Type","licenseType","licenseName")) {
        if ($data | Get-Member -Name $try -ErrorAction SilentlyContinue) {
            $groupField = $try
            break
        }
    }

    if ($groupField) {
        $summary = $data | Group-Object -Property $groupField | ForEach-Object {
            [PSCustomObject]@{
                RobotType = $robotType
                Group     = $_.Name
                Count     = ($_.Count)
                Items     = $_.Group
            }
        }
        Write-Host "Resumen por $groupField para $robotType:"
        $summary | Format-Table -AutoSize
    } else {
        Write-Host "No se detectó un campo obvio para agrupar. Detalle de elementos (primeros 10):"
        $data | Select-Object -First 10 | Format-List
    }
}

# Lista de robotTypes (según la pantalla que mostraste). Agrega o quita según necesites.
$robotTypesList = @(
    "NonProduction","Attended","Unattended","Development","Studio","RpaDeveloper","StudioX","CitizenDeveloper",
    "Headless","StudioPro","RpaDeveloperPro","TestAutomation","AutomationCloud","Serverless","AutomationKit",
    "ServerlessTestAutomation","AutomationCloudTestAutomation","AttendedStudioWeb","Hosting","AssistantWeb",
    "ProcessOrchestration","AgentService","AppTest","PerformanceTest","BusinessRule","CaseManagement"
)

# 1) Obtener token
$token = Get-AuthToken -ClientId $ClientId -ClientSecret $ClientSecret
if (-not $token) { Write-Error "No se obtuvo token. Abortando."; exit 1 }

# 2) Si pides ALL, itera; sino consulta el RobotType solicitado
if ($RobotType -eq "ALL") {
    foreach ($rt in $robotTypesList) {
        $resp = Get-LicensesForRobotType -accessToken $token -account $AccountLogicalName -tenant $TenantLogicalName -robotType $rt
        Summarize-Licenses -resp $resp -robotType $rt
    }
} else {
    $resp = Get-LicensesForRobotType -accessToken $token -account $AccountLogicalName -tenant $TenantLogicalName -robotType $RobotType
    Summarize-Licenses -resp $resp -robotType $RobotType
}
