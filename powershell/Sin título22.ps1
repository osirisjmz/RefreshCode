$portCheck = Get-NetTCPConnection -LocalPort 1433 -State Listen

if ($portCheck) {
    Write-Host "✅ El puerto 1433 está en estado LISTEN. SQL Server está aceptando conexiones."
} else {
    Write-Host "❌ El puerto 1433 no está en estado LISTEN. SQL Server no está escuchando en ese puerto."
}
