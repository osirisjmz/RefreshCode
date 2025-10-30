# ============================================================
# Script: Setup-MLL-Env.ps1
# Propósito: Reconfigura entorno virtual Python (3.12.6)
#             y reinstala todas las librerías desde requirements.txt
# Autor: Osiris Jimenez
# ============================================================

Write-Host "🚀 Iniciando configuración del entorno Python 3.12.6..." -ForegroundColor Cyan

# --- VARIABLES ---
$projectPath = "C:\Users\OcyriZ\Documents\RefreshCode"
$pythonPath  = "C:\RPA\Python312\python.exe"
$venvPath    = "$projectPath\.venv"
$reqFile     = "$projectPath\requirements.txt"

# --- VALIDACIÓN DE EXISTENCIA ---
if (-Not (Test-Path $pythonPath)) {
    Write-Host "❌ ERROR: No se encontró Python en la ruta $pythonPath" -ForegroundColor Red
    Write-Host "Instálalo en C:\RPA\Python312 antes de continuar." -ForegroundColor Yellow
    exit
}

if (-Not (Test-Path $reqFile)) {
    Write-Host "❌ ERROR: No se encontró el archivo requirements.txt en $reqFile" -ForegroundColor Red
    exit
}

# --- ELIMINAR ENTORNO ANTIGUO ---
if (Test-Path $venvPath) {
    Write-Host "🧹 Eliminando entorno anterior (.venv)..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $venvPath
}

# --- CREAR NUEVO ENTORNO VIRTUAL ---
Write-Host "⚙️  Creando nuevo entorno virtual..." -ForegroundColor Cyan
& $pythonPath -m venv $venvPath

# --- ACTIVAR ENTORNO ---
$activatePath = "$venvPath\Scripts\Activate.ps1"
if (Test-Path $activatePath) {
    Write-Host "✅ Activando entorno..." -ForegroundColor Green
    & $activatePath
} else {
    Write-Host "❌ ERROR: No se encontró el archivo Activate.ps1" -ForegroundColor Red
    exit
}

# --- ACTUALIZAR PIP Y TOOLS ---
Write-Host "⬆️  Actualizando pip, setuptools y wheel..." -ForegroundColor Cyan
python -m pip install --upgrade pip setuptools wheel

# --- INSTALAR DEPENDENCIAS ---
Write-Host "📦 Instalando librerías desde requirements.txt..." -ForegroundColor Cyan
pip install -r $reqFile

# --- VERIFICACIÓN ---
Write-Host "`n🔍 Verificación final:" -ForegroundColor Green
python --version
pip list

Write-Host "`n✅ Configuración completada exitosamente." -ForegroundColor Green
Write-Host "Entorno virtual disponible en: $venvPath" -ForegroundColor Cyan
