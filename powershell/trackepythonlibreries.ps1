<#
.SYNOPSIS
    Lista todas las librerías instaladas dentro de un entorno virtual de Python (.venv).

.PARAMETER VenvPath
    Ruta completa del entorno virtual a inspeccionar (ejemplo: C:\Users\Ocyriz\Documents\RefreshCode\.venv).

.EXAMPLE
    .\List-VenvPackages.ps1 -VenvPath "C:\Users\Ocyriz\Documents\RefreshCode\.venv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VenvPath
)

# Validar ruta del entorno
if (!(Test-Path $VenvPath)) {
    Write-Host "❌ El entorno virtual no existe en la ruta especificada: $VenvPath" -ForegroundColor Red
    exit
}

# Definir ruta del ejecutable de Python
$pythonExe = Join-Path $VenvPath "Scripts\python.exe"

if (!(Test-Path $pythonExe)) {
    Write-Host "❌ No se encontró python.exe en el entorno especificado." -ForegroundColor Red
    exit
}

# Mostrar información del entorno
Write-Host "✅ Usando intérprete:" $pythonExe -ForegroundColor Cyan
Write-Host "📦 Listando paquetes instalados..." -ForegroundColor Yellow

# Ejecutar pip list dentro del entorno
try {
    & $pythonExe -m pip list | Tee-Object -FilePath "$env:USERPROFILE\Desktop\venv_packages_list.txt"
    Write-Host "`n📄 Lista guardada en tu Escritorio como 'venv_packages_list.txt'" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Error al intentar listar los paquetes: $($_.Exception.Message)" -ForegroundColor Red
}
