<#
    Script: Install-Python310-UiPathCompatible.ps1
    Autor: Osiris Jiménez (versión ajustada)
    Descripción: Instala Python 3.10.11 (64-bit) compatible con UiPath y verifica entorno
#>

$PythonRoot = "C:\RPA\Python310"
$PythonExe = "$PythonRoot\python.exe"
$InstallerUrl = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"
$InstallerFile = "$env:TEMP\python-3.10.11-amd64.exe"

Write-Host "🚀 Instalando Python 3.10.11 compatible con UiPath..." -ForegroundColor Cyan

# Crear carpeta base
if (-not (Test-Path "C:\RPA")) {
    New-Item -ItemType Directory -Path "C:\RPA" | Out-Null
}

# Descargar instalador si no existe
if (-not (Test-Path $InstallerFile)) {
    Write-Host "⬇️  Descargando instalador desde $InstallerUrl..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerFile
}

# Instalar silenciosamente
if (-not (Test-Path $PythonExe)) {
    Write-Host "⚙️  Instalando Python 3.10.11..." -ForegroundColor Yellow
    Start-Process -FilePath $InstallerFile -ArgumentList "/quiet InstallAllUsers=1 PrependPath=0 Include_pip=1 TargetDir=$PythonRoot" -Wait
} else {
    Write-Host "✔️  Python 3.10 ya está instalado." -ForegroundColor Green
}

# Agregar rutas al PATH
$envPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
if ($envPath -notlike "*$PythonRoot*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$PythonRoot;$PythonRoot\Scripts", "Machine")
    Write-Host "✅ Rutas agregadas al PATH: $PythonRoot" -ForegroundColor Green
} else {
    Write-Host "ℹ️  PATH ya contenía las rutas necesarias." -ForegroundColor Gray
}

# Validar instalación
Write-Host "`n🔍 Verificando instalación..." -ForegroundColor Cyan
& "$PythonExe" --version
& "$PythonExe" -m pip --version

Write-Host "`n✅ Instalación completada: Python 3.10.11 (64-bit) lista para UiPath." -ForegroundColor Green
