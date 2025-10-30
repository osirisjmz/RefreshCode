param(
    [string]$RobotName,
    [string]$DomainUser,
    [string]$Password,
    [string]$MachineTemplateName,
    [string]$TenantLogicalName,
    [string]$AccountLogicalName,
    [string]$ClientId,
    [string]$ClientSecret,
    [string]$OutputLogPath
)

try {
    $authBody = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "OR.Robots"
    }
    $authResponse = Invoke-RestMethod -Method Post -Uri "https://cloud.uipath.com/identity_/connect/token" -Body $authBody
    $token = $authResponse.access_token

    $headers = @{ Authorization = "Bearer $token" }
    $baseUrl = "https://cloud.uipath.com/$AccountLogicalName/$TenantLogicalName/odata"

    $robotCheck = Invoke-RestMethod -Method Get -Uri "$baseUrl/Robots?`$filter=Name eq '$RobotName'" -Headers $headers
    if ($robotCheck.value.Count -gt 0) {
        $msg = "Robot '$RobotName' ya existe con ID: $($robotCheck.value[0].Id)"
        Add-Content -Path $OutputLogPath -Value $msg
        Write-Output $msg
        return
    }

    $machines = Invoke-RestMethod -Uri "$baseUrl/MachineTemplates" -Headers $headers
    $machine = $machines.value | Where-Object { $_.Name -eq $MachineTemplateName }
    if (-not $machine) {
        $msg = "Machine Template '$MachineTemplateName' no encontrada para robot '$RobotName'"
        Add-Content -Path $OutputLogPath -Value $msg
        Write-Output $msg
        return
    }

    $body = @{
        Name                 = $RobotName
        Username             = $DomainUser
        Password             = $Password
        MachineTemplateId    = $machine.Id
        Type                 = "Unattended"
        ExecutionSettings    = @{ "ExecutionType" = "Foreground" }
        CredentialType       = "Windows"
        Description          = "Robot creado via script PowerShell"
    }
    $jsonBody = $body | ConvertTo-Json -Depth 5
    $newRobot = Invoke-RestMethod -Uri "$baseUrl/Robots" -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json"

    $msg = "Robot '$RobotName' creado exitosamente con ID: $($newRobot.Id)"
    Add-Content -Path $OutputLogPath -Value $msg
    Write-Output $msg

} catch {
    $errorMessage = "ERROR en Robot '$RobotName': $($_.Exception.Message)"
    Add-Content -Path $OutputLogPath -Value $errorMessage
    Write-Output $errorMessage
}
