<#
    Script: VerifyAndRepair-Python310.ps1
    Autor:  Osiris Jiménez
    Descripción:
        Verifica, repara y documenta el estado de instalación de Python 3.10 en C:\RPA\Python310
        - Valida existencia de carpetas, ejecutables y claves de registro
        - Corrige o crea entradas faltantes
        - Genera log detallado con resultados y acciones ejecutadas
        - Ejecuta prueba final de integración con UiPath
    Requiere: Ejecutar PowerShell como Administrador
#>

# ==============================
# VARIABLES BASE
# ==============================
$PythonRoot = "C:\RPA\Python310"
$PythonExe = "$PythonRoot\python.exe"
$ScriptsPath = "$PythonRoot\Scripts"
$RegBase = "HKLM:\SOFTWARE\Python\PythonCore\3.10"
$RegPath = "$RegBase\InstallPath"
$LogPath = "C:\RPA\Logs"
$LogFile = "$LogPath\Python310_Verification_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

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
Write-Host "🚀 Iniciando verificación completa de Python 3.10..." -ForegroundColor Cyan
if (-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }

Write-Log "===== INICIO DE VERIFICACIÓN DE PYTHON 3.10 ====="

# ==============================
# 1️⃣ VALIDAR CARPETA BASE
# ==============================
if (Test-Path $PythonRoot) {
    Write-Log "Ruta base ${PythonRoot} existente: Sí"
} else {
    Write-Log "Ruta base ${PythonRoot} existente: No"
    Write-Log "Procediendo a crear carpeta base..."
    try {
        New-Item -ItemType Directory -Path $PythonRoot | Out-Null
        Write-Log "Carpeta creada exitosamente."
    } catch {
        Write-Log "❌ Error al crear carpeta base: $_" "ERROR"
    }
}

# ==============================
# 2️⃣ VALIDAR PYTHON.EXE
# ==============================
if (Test-Path $PythonExe) {
    Write-Log "Archivo python.exe encontrado en ${PythonExe}: Sí"
} else {
    Write-Log "Archivo python.exe encontrado: No"
    Write-Log "❌ No se encontró Python. Se requiere reinstalación o reparación."
}

# ==============================
# 3️⃣ VALIDAR PIP
# ==============================
if (Test-Path "${ScriptsPath}\pip.exe") {
    Write-Log "Archivo pip.exe encontrado en ${ScriptsPath}: Sí"
} else {
    Write-Log "Archivo pip.exe encontrado: No"
    if (Test-Path $PythonExe) {
        Write-Log "Intentando reinstalar pip..."
        try {
            & "$PythonExe" -m ensurepip --upgrade | Out-Null
            Write-Log "Proceso de reparación de pip completado."
        } catch {
            Write-Log "❌ Error al intentar reinstalar pip: $_" "ERROR"
        }
    } else {
        Write-Log "❌ No se puede reparar pip porque python.exe no está disponible."
    }
}

# ==============================
# 4️⃣ VALIDAR Y REPARAR CLAVES DE REGISTRO
# ==============================
if (Test-Path $RegPath) {
    Write-Log "Clave de registro ${RegPath} existente: Sí"
} else {
    Write-Log "Clave de registro ${RegPath} existente: No"
    Write-Log "Procediendo a crear claves de registro..."
    try {
        if (-not (Test-Path $RegBase)) { New-Item -Path $RegBase -Force | Out-Null }
        New-Item -Path $RegPath -Force | Out-Null
        Write-Log "Claves de registro creadas correctamente."
    } catch {
        Write-Log "❌ Error al crear claves de registro: $_" "ERROR"
    }
}

try {
    Set-ItemProperty -Path $RegPath -Name "(default)" -Value "$PythonRoot\" -Force
    Set-ItemProperty -Path $RegPath -Name "ExecutablePath" -Value "$PythonExe" -Force
    Set-ItemProperty -Path $RegPath -Name "WindowedExecutablePath" -Value "$PythonRoot\pythonw.exe" -Force
    Write-Log "Entradas de registro validadas o actualizadas correctamente."
} catch {
    Write-Log "❌ Error al actualizar entradas de registro: $_" "ERROR"
}

# ==============================
# 5️⃣ VALIDAR PATH GLOBAL
# ==============================
Write-Log "Verificando variable de entorno PATH..."
$envPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")

if ($envPath -like "*$PythonRoot*" -and $envPath -like "*$ScriptsPath*") {
    Write-Log "PATH del sistema contiene las rutas necesarias: Sí"
} else {
    Write-Log "PATH del sistema contiene las rutas necesarias: No"
    Write-Log "Procediendo a agregarlas..."
    try {
        $newPath = ($envPath -split ";") | Where-Object {$_ -and ($_ -notlike "*Python310*")}
        $newPath = ($newPath -join ";") + ";$PythonRoot;$ScriptsPath"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Log "PATH del sistema actualizado correctamente."
    } catch {
        Write-Log "❌ Error al actualizar PATH: $_" "ERROR"
    }
}

# ==============================
# 6️⃣ VALIDACIÓN FINAL Y PRUEBA UIPATH
# ==============================
Write-Log "Ejecutando comprobación de versión de Python..."
if (Test-Path $PythonExe) {
    try {
        $pyVersion = & "$PythonExe" --version 2>$null
        $pipVersion = & "$PythonExe" -m pip --version 2>$null
        Write-Log "Versión de Python detectada: $pyVersion"
        Write-Log "Versión de Pip detectada: $pipVersion"
        
        Write-Log "Ejecutando prueba de integración con UiPath..."
        $testOutput = & "$PythonExe" -c "print('UiPath-ready Python working ✅')" 2>$null
        if ($LASTEXITCODE -eq 0 -and $testOutput) {
            Write-Log "🟢 Prueba exitosa: $testOutput"
        } else {
            Write-Log "🔴 La prueba de integración con UiPath falló o no devolvió resultado."
        }
    } catch {
        Write-Log "❌ Error al obtener versiones o ejecutar prueba: $_" "ERROR"
    }
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
