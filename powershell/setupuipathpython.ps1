# ============================================================
# Setup-Python311-UiPath.ps1
# Instalación completa y validación del entorno Python 3.11 para UiPath
# Autor: Osiris Jimenez
# ============================================================

Write-Host "🚀 Iniciando setup del entorno Python 3.11 para UiPath..." -ForegroundColor Cyan

# ----- Ruta base -----
$pythonPath = "C:\Program Files\Python311\python.exe"
$scriptsPath = "C:\Program Files\Python311\Scripts"
$logFile = "$PSScriptRoot\PythonSetupLog.txt"

# ----- Verificar existencia -----
if (-not (Test-Path $pythonPath)) {
    Write-Host "❌ ERROR: No se encontró Python en la ruta: $pythonPath" -ForegroundColor Red
    Write-Host "Por favor instálalo con la opción 'Install for all users' antes de continuar." -ForegroundColor Yellow
    exit
}

# ----- Crear log -----
"==== Python 3.11 Setup Log - $(Get-Date) ====" | Out-File $logFile

# ----- Mostrar versión -----
Write-Host "`n📦 Verificando versión de Python..."
& $pythonPath --version | Tee-Object -FilePath $logFile -Append

# ============================================================
# 1️⃣ Verificar y agregar 'Scripts' al PATH
# ============================================================

Write-Host "`n🔧 Verificando variable PATH del sistema..."
$envPaths = [Environment]::GetEnvironmentVariable("Path", "Machine").Split(";")

if ($envPaths -notcontains $scriptsPath) {
    Write-Host "➕ Agregando '$scriptsPath' a PATH del sistema..." -ForegroundColor Yellow
    $newPaths = ($envPaths + $scriptsPath) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPaths, "Machine")
    "PATH actualizado: $scriptsPath agregado" | Out-File $logFile -Append
} else {
    Write-Host "✅ '$scriptsPath' ya está en PATH." -ForegroundColor Green
    "PATH existente OK" | Out-File $logFile -Append
}

# ============================================================
# 2️⃣ Activar pip y actualizarlo
# ============================================================
Write-Host "`n📦 Verificando pip..."
& $pythonPath -m ensurepip | Tee-Object -FilePath $logFile -Append
& $pythonPath -m pip install --upgrade pip --no-warn-script-location | Tee-Object -FilePath $logFile -Append

# ============================================================
# 3️⃣ Instalar librerías necesarias
# ============================================================
Write-Host "`n📦 Instalando librerías (playwright, pandas, openpyxl, requests, python-dateutil)..."
& $pythonPath -m pip install playwright pandas openpyxl requests python-dateutil --no-warn-script-location | Tee-Object -FilePath $logFile -Append

# ============================================================
# 4️⃣ Instalar navegadores de Playwright
# ============================================================
Write-Host "`n🌐 Instalando navegadores de Playwright (Chromium)..."
& $pythonPath -m playwright install chromium | Tee-Object -FilePath $logFile -Append

# ============================================================
# 5️⃣ Validaciones automáticas
# ============================================================
Write-Host "`n🧠 Validando entorno..."

try {
    & $pythonPath -c "from playwright.sync_api import sync_playwright; print('✅ Playwright importado correctamente')"
    & $pythonPath -c "import pandas as pd; print('✅ Pandas importado correctamente, versión:', pd.__version__)"
    "Validaciones: OK" | Out-File $logFile -Append
}
catch {
    Write-Host "⚠️ Error en validación de librerías." -ForegroundColor Red
    "Validaciones: ERROR $_" | Out-File $logFile -Append
}

# ============================================================
# 6️⃣ Confirmación final
# ============================================================
Write-Host "`n✅ Setup completado exitosamente." -ForegroundColor Green
Write-Host "📄 Log guardado en: $logFile" -ForegroundColor Yellow
Write-Host "Ruta del ejecutable: $pythonPath" -ForegroundColor White
Write-Host "Librerías: $($pythonPath.Replace('python.exe','Lib\site-packages'))" -ForegroundColor White
Write-Host "Ahora puedes configurar esta ruta en tu Python Scope de UiPath." -ForegroundColor Green
# ============================================================
