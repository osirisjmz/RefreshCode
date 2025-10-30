# ============================================================
# Setup-Python311-UiPath.ps1
# Instala todas las librerías necesarias para UiPath + Playwright
# y valida la configuración de Python 3.10 en Program Files
# Autor: Osiris Jimenez
# ============================================================

Write-Host "🚀 Iniciando setup del entorno Python 3.11 para UiPath..." -ForegroundColor Cyan

# ----- Ruta del ejecutable de Python -----
$pythonPath = "C:\RPA\Python312\python.exe"

# ----- Verificación de existencia -----
if (-not (Test-Path $pythonPath)) {
    Write-Host "❌ ERROR: No se encontró Python en la ruta: $pythonPath" -ForegroundColor Red
    Write-Host "Verifica que lo instalaste para todos los usuarios (C:\RPA\Python312\)" -ForegroundColor Yellow
    exit
}

# ----- Mostrar versión -----
Write-Host "`n📦 Verificando versión instalada..."
& $pythonPath --version

# ----- Activar pip -----
Write-Host "`n🔧 Asegurando instalación de pip..."
& $pythonPath -m ensurepip
& $pythonPath -m pip install --upgrade pip

# ----- Instalar librerías necesarias -----
Write-Host "`n📦 Instalando librerías necesarias (playwright, pandas, openpyxl, requests, python-dateutil)..."
& $pythonPath -m pip install playwright pandas openpyxl requests python-dateutil

# ----- Instalar navegadores de Playwright -----
Write-Host "`n🌐 Instalando navegadores de Playwright (Chromium)..."
& $pythonPath -m playwright install chromium

# ----- Mostrar ruta de instalación de librerías -----
Write-Host "`n📁 Ubicación actual de librerías:"
& $pythonPath -m site

# ----- Validación: importar Playwright -----
Write-Host "`n🧠 Probando importación de Playwright..."
try {
    & $pythonPath -c "from playwright.sync_api import sync_playwright; print('✅ Playwright importado correctamente')"
}
catch {
    Write-Host "⚠️ Error al importar Playwright. Revisa permisos o reinstala dependencias." -ForegroundColor Red
}

# ----- Validación adicional: Pandas -----
Write-Host "`n📊 Probando importación de Pandas..."
try {
    & $pythonPath -c "import pandas as pd; print('✅ Pandas importado correctamente, versión:', pd.__version__)"
}
catch {
    Write-Host "⚠️ Error al importar Pandas." -ForegroundColor Red
}

# ----- Confirmación final -----
Write-Host "`n✅ Instalación completada exitosamente." -ForegroundColor Green
Write-Host "Ruta del ejecutable: $pythonPath" -ForegroundColor White
Write-Host "Usa esta ruta en tu Python Scope dentro de UiPath." -ForegroundColor Yellow
# ============================================================
