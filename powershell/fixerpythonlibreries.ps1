<#
.SYNOPSIS
    Repara un entorno virtual de Python dañado (pip roto o versión cambiada)
    y reinstala todas las dependencias desde requirements.txt.

.PARAMETER PythonPath
    Ruta al ejecutable de Python correcto (por ejemplo: C:\RPA\Python39\python.exe)

.PARAMETER VenvPath
    Ruta del entorno virtual a reparar (por ejemplo: C:\Users\Ocyriz\Documents\RefreshCode\.venv)

.PARAMETER RequirementsPath
    Ruta del archivo requirements.txt con las librerías a instalar

.EXAMPLE
    .\Fix-Venv.ps1 -PythonPath "C:\RPA\Python39\python.exe" `
                   -VenvPath "C:\Users\Ocyriz\Documents\RefreshCode\.venv" `
                   -RequirementsPath "C:\Users\Ocyriz\Documents\requirements.txt"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PythonPath,

    [Parameter(Mandatory = $true)]
    [string]$VenvPath,

    [Parameter(Mandatory = $true)]
    [string]$RequirementsPath
)

Write-Host "🔧 Reparando entorno virtual..." -ForegroundColor Cyan

# 1️⃣ Validar rutas
if (!(Test-Path $PythonPath)) { Write-Host "❌ No se encontró Python en $PythonPath" -ForegroundColor Red; exit }
if (!(Test-Path $VenvPath)) { Write-Host "❌ No se encontró el entorno virtual en $VenvPath" -ForegroundColor Red; exit }
if (!(Test-Path $RequirementsPath)) { Write-Host "⚠️ No se encontró requirements.txt en $RequirementsPath" -ForegroundColor Yellow }

# 2️⃣ Reconfigurar entorno con el Python correcto
Write-Host "➡️ Ejecutando: python -m venv --upgrade ..." -ForegroundColor Yellow
& $PythonPath -m venv --upgrade $VenvPath

# 3️⃣ Activar entorno virtual
$activate = Join-Path $VenvPath "Scripts\activate.ps1"
if (Test-Path $activate) {
    Write-Host "✅ Activando entorno virtual..." -ForegroundColor Green
    & $activate
} else {
    Write-Host "⚠️ No se encontró el script de activación." -ForegroundColor Yellow
}

# 4️⃣ Reinstalar pip y herramientas base
Write-Host "🔄 Reinstalando pip, setuptools y wheel..." -ForegroundColor Yellow
& (Join-Path $VenvPath "Scripts\python.exe") -m ensurepip --upgrade
& (Join-Path $VenvPath "Scripts\python.exe") -m pip install --upgrade pip setuptools wheel

# 5️⃣ Instalar dependencias
if (Test-Path $RequirementsPath) {
    Write-Host "📦 Instalando librerías desde requirements.txt..." -ForegroundColor Yellow
    & (Join-Path $VenvPath "Scripts\python.exe") -m pip install -r $RequirementsPath
    Write-Host "✅ Instalación completada correctamente." -ForegroundColor Green
} else {
    Write-Host "⚠️ No se encontró archivo requirements.txt, se omitió la instalación de librerías." -ForegroundColor Yellow
}

# 6️⃣ Verificar
Write-Host "`n📋 Verificando entorno reparado..." -ForegroundColor Cyan
& (Join-Path $VenvPath "Scripts\python.exe") --version
& (Join-Path $VenvPath "Scripts\python.exe") -m pip --version
