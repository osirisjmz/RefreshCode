# Verificar si ya existe una regla que permita el puerto 1433
$rule = Get-NetFirewallRule | Where-Object {
    ($_.DisplayName -eq "SQL Server 1433") -or
    ($_.Direction -eq "Inbound" -and $_.Enabled -eq "True" -and $_.Action -eq "Allow")
}

# Si no existe, se crea la regla
if (-not $rule) {
    New-NetFirewallRule -DisplayName "SQL Server 1433" `
                        -Direction Inbound `
                        -LocalPort 1433 `
                        -Protocol TCP `
                        -Action Allow `
                        -Profile Any

    Write-Host "✅ Puerto 1433 habilitado exitosamente en el firewall."
} else {
    Write-Host "ℹ️ El puerto 1433 ya está habilitado en el firewall."
}
