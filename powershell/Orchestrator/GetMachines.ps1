# === CONFIGURACION ===
$token = "rt_44A2B8AC7189E9013D0AA172D932E3677ECE1050FF624905695D1DF0CF77551C-1"
$account = "hexawyeciivv"
$tenant = "DefaultTenant"
$folderId = 852842  # Reemplaza con el ID real de tu folder si es diferente

# === ENDPOINT ===
$uri = "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/Robots?`$count=true"

# === CABECERAS ===
$headers = @{
    Authorization              = "Bearer $token"
    Accept                     = "application/json"
    "X-UIPATH-OrganizationUnitId" = $folderId
}

# === LLAMADA A LA API ===
try {
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
    Write-Host "`nTotal de robots encontrados: $($response.'@odata.count')`n"
    $response.value | ForEach-Object {
        Write-Host "- ID: $($_.Id), Nombre: $($_.Name), Tipo: $($_.Type), Maquina: $($_.MachineName)"
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)"
}
