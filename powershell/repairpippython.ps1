<#
.SYNOPSIS
    Repara un entorno virtual (.venv) en el que pip.exe está roto o falta.

.PARAMETER PythonPath
    Ruta completa del Python correcto (ej. C:\RPA\Python39\python.exe)

.PARAMETER VenvPath
    Ruta del entorno virtual a reparar (ej. C:\Users\Ocyriz\Documents\RefreshCode\.venv)

.EXAMPLE
    .\Repair-Pip.ps1 -PythonPath "C:\RPA\Python39\python.exe" -VenvPath "C:\Users\Ocyriz\Documents\RefreshCode\.venv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PythonPath,

    [Parameter(Mandatory = $true)]
    [string]$VenvPath
)

# 🧩 Validar rutas
if (!(Test-Path $PythonPath)) {
    Write-Host "❌ No se encontró Python en la ruta especificada: $PythonPath" -ForegroundColor Red
    exit
}
if (!(Test-Path $VenvPath)) {
    Write-Host "❌ No se encontró el entorno virtual: $VenvPath" -ForegroundColor Red
    exit
}

$PipExe = Join-Path $VenvPath "Scripts\pip.exe"
$PyExe = Join-Path $VenvPath "Scripts\python.exe"

Write-Host "`n🔍 Verificando entorno..." -ForegroundColor Cyan

if (Test-Path $PipExe) {
    Write-Host "⚠️ Eliminando pip.exe roto..." -ForegroundColor Yellow
    Remove-Item $PipExe -Force -ErrorAction SilentlyContinue
}

# 🛠️ Reparar usando el Python correcto
Write-Host "`n🔧 Reparando pip dentro del entorno virtual..." -ForegroundColor Cyan
& $PythonPath -m venv --upgrade $VenvPath

Write-Host "📦 Ejecutando ensurepip..." -ForegroundColor Yellow
& $PyExe -m ensurepip --upgrade

Write-Host "📦 Actualizando pip, setuptools y wheel..." -ForegroundColor Yellow
& $PyExe -m pip install --upgrade pip setuptools wheel

# ✅ Verificar reparación
Write-Host "`n✅ Verificación final:" -ForegroundColor Green
& $PyExe --version
& $PyExe -m pip --version
