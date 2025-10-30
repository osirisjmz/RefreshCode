<#
.SYNOPSIS
    Verifica, instala y repara entornos Python:
      - 3.9.13 para UiPath en C:\RPA\Python39
      - 3.12.6 para IA en C:\RPA\Python312
    También instala dependencias desde requirements.txt si existe.
.AUTOR
    Osiris Jiménez | v2025.10.22
#>

# ==============================
# CONFIGURACIÓN BASE
# ==============================
$BasePath       = "C:\Users\Ocyriz\Documents\RefreshCode"
$Python39Root   = "C:\RPA\Python39"
$Python312Root  = "C:\RPA\Python312"
$Requirements   = "$BasePath\requirements.txt"
$LogPath        = "C:\RPA\Logs"
if (-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }
$LogFile        = "$LogPath\PythonEnv_Verification_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$Python39Url    = "https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe"
$Python312Url   = "https://www.python.org/ftp/python/3.12.6/python-3.12.6-amd64.exe"
$Temp39         = "$env:TEMP\python-3.9.13-amd64.exe"
$Temp312        = "$env:TEMP\python-3.12.6-amd64.exe"

$Python39Exe    = "$Python39Root\python.exe"
$Python312Exe   = "$Python312Root\python.exe"

# ==============================
# FUNCIÓN PARA LOGUEAR
# ==============================
function Write-Log {
    param([string]$Message,[string]$Type="INFO")
    $time=(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line="[$time][$Type] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

# ==============================
# FUNCIÓN: INSTALAR PYTHON SI NO EXISTE
# ==============================
function Install-Python {
    param([string]$Version,[string]$Url,[string]$Target,[string]$TempFile)
    if (!(Test-Path "$Target\python.exe")) {
        Write-Log "🔧 Python $Version no encontrado, iniciando instalación..."
        if (!(Test-Path $TempFile)) {
            Write-Log "Descargando instalador desde $Url..."
            Invoke-WebRequest -Uri $Url -OutFile $TempFile
        }
        Start-Process -FilePath $TempFile -ArgumentList "/quiet InstallAllUsers=1 PrependPath=0 Include_pip=1 TargetDir=$Target" -Wait
        Write-Log "✅ Python $Version instalado en $Target"
    } else {
        Write-Log "✔️ Python $Version ya instalado en $Target"
    }
}

# ==============================
# FUNCIÓN: REPARAR PIP
# ==============================
function Repair-Pip {
    param([string]$PythonExe)
    Write-Log "🧩 Reparando pip en $PythonExe"
    & $PythonExe -m ensurepip --upgrade
    & $PythonExe -m pip install --upgrade pip setuptools wheel --no-warn-script-location
}

# ==============================
# FUNCIÓN: INSTALAR DEPENDENCIAS
# ==============================
function Install-Requirements {
    param([string]$PythonExe,[string]$ReqFile)
    if (Test-Path $ReqFile) {
        Write-Log "📦 Instalando dependencias desde $ReqFile"
        try {
            & $PythonExe -m pip install --no-cache-dir -r $ReqFile --no-warn-script-location
            Write-Log "✅ Dependencias instaladas correctamente."
        } catch {
            Write-Log "⚠️ Error al instalar dependencias: $_" "ERROR"
        }
    } else {
        Write-Log "ℹ️ No se encontró requirements.txt en $ReqFile"
    }
}

# ==============================
# INICIO DE PROCESO
# ==============================
Write-Host "🚀 Iniciando verificación de entornos Python 3.9 y 3.12..." -ForegroundColor Cyan
Write-Log "===== INICIO DE VERIFICACIÓN ====="

# 1️⃣ Verificar/instalar Python 3.9 (UiPath)
Install-Python -Version "3.9.13" -Url $Python39Url -Target $Python39Root -TempFile $Temp39
if (Test-Path $Python39Exe) { Repair-Pip -PythonExe $Python39Exe }

# 2️⃣ Verificar/instalar Python 3.12 (VS Code / IA)
Install-Python -Version "3.12.6" -Url $Python312Url -Target $Python312Root -TempFile $Temp312
if (Test-Path $Python312Exe) { Repair-Pip -PythonExe $Python312Exe }

# 3️⃣ Instalar dependencias IA
Install-Requirements -PythonExe $Python312Exe -ReqFile $Requirements

# 4️⃣ Verificación final
Write-Log "===== VERSIONES DETECTADAS ====="
if (Test-Path $Python39Exe)  { Write-Log "Python 3.9 → $(& $Python39Exe --version)" }
if (Test-Path $Python312Exe) { Write-Log "Python 3.12 → $(& $Python312Exe --version)" }
Write-Log "================================"
Write-Host "`n📋 Log generado en: $LogFile" -ForegroundColor Green
