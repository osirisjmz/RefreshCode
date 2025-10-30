<#
    Script: VerifyAndRepair-Python311.ps1
    Autor:  Osiris Jiménez
    Descripción:
        Verifica, repara y documenta el estado de instalación de Python 3.11 en C:\RPA\Python311
        - Valida existencia de carpetas, ejecutables y claves de registro
        - Corrige o crea entradas faltantes
        - Genera un log detallado con resultados y acciones ejecutadas
        - Deja todo listo para integrarse con UiPath
    Requiere: Ejecutar PowerShell como Administrador
#>

# ==============================
# VARIABLES BASE
# ==============================
$PythonRoot = "C:\RPA\Python311"
$PythonExe = "$PythonRoot\python.exe"
$ScriptsPath = "$PythonRoot\Scripts"
$RegPath = "HKLM:\SOFTWARE\Python\PythonCore\3.11\InstallPath"
$LogPath = "C:\RPA\Logs"
$LogFile = "$LogPath\Python311_Verification_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# ==============================
# FUNCIÓN PARA LOGUEAR
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
Write-Host "🚀 Iniciando verificación completa de Python 3.11..." -ForegroundColor Cyan
if (-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }

Write-Log "===== INICIO DE VERIFICACIÓN DE PYTHON 3.11 ====="

# ==============================
# 1️⃣ VALIDAR CARPETA BASE
# ==============================
if (Test-Path $PythonRoot) {
    Write-Log "Ruta base $PythonRoot existente: Sí"
} else {
    Write-Log "Ruta base $PythonRoot existente: No"
    Write-Log "Procediendo a crear carpeta base..."
    New-Item -ItemType Directory -Path $PythonRoot | Out-Null
    Write-Log "Carpeta creada exitosamente."
}

# ==============================
# 2️⃣ VALIDAR PYTHON.EXE
# ==============================
if (Test-Path $PythonExe) {
    Write-Log "Archivo python.exe encontrado en $PythonExe: Sí"
} else {
    Write-Log "Archivo python.exe encontrado: No"
    Write-Log "❌ No se encontró Python. Se requiere reinstalación o reparación."
}

# ==============================
# 3️⃣ VALIDAR PIP
# ==============================
if (Test-Path "$ScriptsPath\pip.exe") {
    Write-Log "Archivo pip.exe encontrado en $ScriptsPath: Sí"
} else {
    Write-Log "Archivo pip.exe encontrado: No"
    if (Test-Path $PythonExe) {
        Write-Log "Intentando reinstalar pip..."
        & "$PythonExe" -m ensurepip --upgrade
        Write-Log "Proceso de reparación de pip completado."
    } else {
        Write-Log "❌ No se puede reparar pip porque python.exe no está disponible."
    }
}

# ==============================
# 4️⃣ VALIDAR Y REPARAR CLAVES DE REGISTRO
# ==============================
if (Test-Path $RegPath) {
    Write-Log "Clave de registro $RegPath existente: Sí"
} else {
    Write-Log "Clave de registro $RegPath existente: No"
    Write-Log "Procediendo a crear claves de registro..."
    New-Item -Path "HKLM:\SOFTWARE\Python\PythonCore\3.11" -Force | Out-Null
    New-Item -Path $RegPath -Force | Out-Null
}

Set-ItemProperty -Path $RegPath -Name "(default)" -Value "$PythonRoot\" -Force
Set-ItemProperty -Path $RegPath -Name "ExecutablePath" -Value "$PythonExe" -Force
Set-ItemProperty -Path $RegPath -Name "WindowedExecutablePath" -Value "$PythonRoot\pythonw.exe" -Force
Write-Log "Entradas de registro validadas o actualizadas correctamente."

# ==============================
# 5️⃣ VALIDAR PATH GLOBAL
# ==============================
$envPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")

if ($envPath -like "*$PythonRoot*" -and $envPath -like "*$ScriptsPath*") {
    Write-Log "PATH del sistema contiene las rutas necesarias: Sí"
} else {
    Write-Log "PATH del sistema contiene las rutas necesarias: No"
    Write-Log "Procediendo a agregarlas..."
    [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$PythonRoot;$ScriptsPath", "Machine")
    Write-Log "PATH del sistema actualizado."
}

# ==============================
# 6️⃣ VALIDACIÓN FINAL
# ==============================
Write-Log "Ejecutando comprobación de versión de Python..."
if (Test-Path $PythonExe) {
    $pyVersion = & "$PythonExe" --version 2>$null
    $pipVersion = & "$PythonExe" -m pip --version 2>$null
    Write-Log "Versión de Python detectada: $pyVersion"
    Write-Log "Versión de Pip detectada: $pipVersion"
} else {
    Write-Log "❌ Python no pudo verificarse porque no se encontró el ejecutable."
}

# ==============================
# 7️⃣ RESULTADO FINAL
# ==============================
Write-Log "===== RESULTADOS FINALES ====="
Write-Log "Ruta base Python: $(Test-Path $PythonRoot)"
Write-Log "Ejecutable Python: $(Test-Path $PythonExe)"
Write-Log "Ruta de Scripts: $(Test-Path $ScriptsPath)"
Write-Log "Pip instalado: $(Test-Path "$ScriptsPath\pip.exe")"
Write-Log "Clave de Registro presente: $(Test-Path $RegPath)"
Write-Log "PATH configurado: $([System.Environment]::GetEnvironmentVariable('Path','Machine') -like "*$PythonRoot*")"

Write-Log "===== FIN DE VERIFICACIÓN ====="
Write-Host "`n📋 Log generado en: $LogFile" -ForegroundColor Green
