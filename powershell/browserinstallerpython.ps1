<#
    Script: Install-PlaywrightBrowsers.ps1
    Autor:  Osiris Jiménez
    Descripción:
        Instala o repara todos los navegadores de Playwright (Chromium, Firefox y WebKit)
        usando la instalación de Python 3.9 en C:\RPA\Python39.
        - Valida la existencia de python.exe
        - Verifica que Playwright esté instalado
        - Instala navegadores Chromium, Firefox y WebKit
        - Genera log de instalación detallado
    Requiere: Ejecutar PowerShell como Administrador
#>

# ==============================
# VARIABLES BASE
# ==============================
$PythonRoot = "C:\RPA\Python39"
$PythonExe = "$PythonRoot\python.exe"
$LogPath = "C:\RPA\Logs"
$LogFile = "$LogPath\Playwright_Browsers_Install_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# ==============================
# FUNCIÓN DE LOG
# ==============================
function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "[$timestamp][$Type] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry
}

# ==============================
# INICIO
# ==============================
Write-Host "🌍 Iniciando instalación de navegadores Playwright..." -ForegroundColor Cyan
if (-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }

Write-Log "===== INICIO DE INSTALACIÓN DE NAVEGADORES PLAYWRIGHT ====="

# ==============================
# 1️⃣ VALIDAR PYTHON
# ==============================
if (-not (Test-Path $PythonExe)) {
    Write-Log "❌ No se encontró Python en ${PythonExe}. Instala Python 3.9 antes de continuar." "ERROR"
    exit
}

# ==============================
# 2️⃣ VALIDAR PLAYWRIGHT
# ==============================
Write-Log "Verificando instalación de Playwright..."
try {
    $pwStatus = & "$PythonExe" -m pip show playwright 2>$null
    if (-not $pwStatus) {
        Write-Log "Playwright no encontrado. Procediendo a instalar..."
        & "$PythonExe" -m pip install playwright -q
        Write-Log "✔️ Playwright instalado correctamente."
    } else {
        Write-Log "✔️ Playwright ya está instalado."
    }
} catch {
    Write-Log "❌ Error al verificar/instalar Playwright: $_" "ERROR"
}

# ==============================
# 3️⃣ INSTALAR TODOS LOS NAVEGADORES
# ==============================
$Browsers = @("chromium", "firefox", "webkit")
foreach ($browser in $Browsers) {
    try {
        Write-Log "🌐 Instalando navegador: ${browser}..."
        & "$PythonExe" -m playwright install $browser
        Write-Log "✔️ Navegador ${browser} instalado correctamente."
    } catch {
        Write-Log "❌ Error al instalar navegador ${browser}: $_" "ERROR"
    }
}

# ==============================
# 4️⃣ CONFIRMACIÓN FINAL
# ==============================
try {
    Write-Log "Verificando componentes instalados..."
    & "$PythonExe" -m playwright install-deps
    Write-Log "🧩 Dependencias de Playwright validadas correctamente."
} catch {
    Write-Log "⚠️ Error al validar dependencias: $_" "WARN"
}

Write-Log "===== INSTALACIÓN DE NAVEGADORES COMPLETA ====="
Write-Host "`n✅ Instalación de navegadores finalizada. Revisa el log en: $LogFile" -ForegroundColor Green
