param(
    [string]$FolderName,
    [string]$RobotId,
    [string]$MachineId,
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
        scope         = "OR.Folders"
    }
    $authResponse = Invoke-RestMethod -Method Post -Uri "https://cloud.uipath.com/identity_/connect/token" -Body $authBody
    $token = $authResponse.access_token

    $headers = @{ Authorization = "Bearer $token" }
    $odataBase = "https://cloud.uipath.com/$AccountLogicalName/$TenantLogicalName/odata"
    $apiBase = "https://cloud.uipath.com/$AccountLogicalName/$TenantLogicalName/api"

    $folders = Invoke-RestMethod -Uri "$apiBase/Folders/GetAllForCurrentUser" -Headers $headers
    $match = $folders | Where-Object { $_.DisplayName -eq $FolderName }

    if ($match) {
        $msg = "Folder '$FolderName' ya existe con ID: $($match.Id)"
        Add-Content -Path $OutputLogPath -Value $msg
        Write-Output $msg
        $folderId = $match.Id
    } else {
        $body = @{
            DisplayName = $FolderName
            FullyQualifiedName = $FolderName
            ProvisionType = "Manual"
            FolderType = "Modern"
        }
        $jsonBody = $body | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$odataBase/Folders" -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json"
        $folderId = $response.Id
        $msg = "Folder '$FolderName' creado con ID: $folderId"
        Add-Content -Path $OutputLogPath -Value $msg
        Write-Output $msg
    }

    $assignMachineBody = @{
        MachineIds = @($MachineId)
        FolderIds  = @($folderId)
    } | ConvertTo-Json -Depth 2
    Invoke-RestMethod -Uri "$odataBase/Folders/UiPath.Server.Configuration.OData.AssignMachines" -Method Post -Headers $headers -Body $assignMachineBody -ContentType "application/json"
    Add-Content -Path $OutputLogPath -Value "Maquina asignada a folder '$FolderName'"

    $assignRobotBody = @(
        @{
            UserId = $RobotId
            FolderId = $folderId
            Roles = @("Automation User")
        }
    ) | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri "$odataBase/Folders/UiPath.Server.Configuration.OData.AssignUsers" -Method Post -Headers $headers -Body $assignRobotBody -ContentType "application/json"
    Add-Content -Path $OutputLogPath -Value "Robot asignado a folder '$FolderName'"

} catch {
    $errorMessage = "ERROR en Folder '$FolderName': $($_.Exception.Message)"
    Add-Content -Path $OutputLogPath -Value $errorMessage
    Write-Output $errorMessage
}
