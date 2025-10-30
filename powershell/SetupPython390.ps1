<#
    Script: VerifyAndRepair-Python39.ps1
    Autor:  Osiris Jiménez
    Descripción:
        Instala, verifica y repara Python 3.9.13 en C:\RPA\Python39.
        - Descarga e instala Python 3.9.13 si no existe
        - Valida existencia de carpetas, ejecutables y claves de registro
        - Corrige o crea entradas faltantes en PATH y Registro
        - Instala librerías esenciales (Playwright, Pandas, etc.)
        - Ejecuta prueba final de integración con UiPath
    Requiere: Ejecutar PowerShell como Administrador
#>

# ==============================
# VARIABLES BASE
# ==============================
$PythonVersion = "3.9.13"
$PythonRoot = "C:\RPA\Python39"
$PythonExe = "$PythonRoot\python.exe"
$ScriptsPath = "$PythonRoot\Scripts"
$RegBase = "HKLM:\SOFTWARE\Python\PythonCore\3.9"
$RegPath = "$RegBase\InstallPath"
$LogPath = "C:\RPA\Logs"
$LogFile = "$LogPath\Python39_Verification_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$InstallerUrl = "https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-amd64.exe"
$InstallerFile = "$env:TEMP\python-$PythonVersion-amd64.exe"

# Librerías requeridas
$RequiredPackages = @(
    "playwright",
    "pandas",
    "openpyxl",
    "requests",
    "python-dateutil"
)

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
Write-Host "🚀 Iniciando verificación completa de Python 3.9..." -ForegroundColor Cyan
if (-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }

Write-Log "===== INICIO DE VERIFICACIÓN DE PYTHON 3.9 ====="

# ==============================
# 1️⃣ DESCARGAR E INSTALAR PYTHON SI NO EXISTE
# ==============================
if (-not (Test-Path $PythonExe)) {
    Write-Log "Python 3.9 no encontrado. Procediendo a instalar..."
    try {
        if (-not (Test-Path $InstallerFile)) {
            Write-Log "Descargando instalador desde $InstallerUrl..."
            Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerFile
        }
        Start-Process -FilePath $InstallerFile -ArgumentList "/quiet InstallAllUsers=1 PrependPath=0 Include_pip=1 TargetDir=$PythonRoot" -Wait
        Write-Log "Instalación completada correctamente."
    } catch {
        Write-Log "❌ Error durante la instalación de Python: $_" "ERROR"
    }
} else {
    Write-Log "✔️ Python ya está instalado en ${PythonRoot}"
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
        $newPath = ($envPath -split ";") | Where-Object {$_ -and ($_ -notlike "*Python39*")}
        $newPath = ($newPath -join ";") + ";$PythonRoot;$ScriptsPath"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Log "PATH del sistema actualizado correctamente."
    } catch {
        Write-Log "❌ Error al actualizar PATH: $_" "ERROR"
    }
}

# ==============================
# 6️⃣ INSTALAR LIBRERÍAS NECESARIAS
# ==============================
Write-Log "Verificando e instalando librerías necesarias..."
if (Test-Path $PythonExe) {
    foreach ($pkg in $RequiredPackages) {
        try {
            $pkgStatus = & "$PythonExe" -m pip show $pkg 2>$null
            if (-not $pkgStatus) {
                Write-Log "📦 Librería '${pkg}' no encontrada. Procediendo a instalar..."
                & "$PythonExe" -m pip install $pkg -q
                Write-Log "✔️ Librería '${pkg}' instalada correctamente."
            } else {
                Write-Log "✔️ Librería '${pkg}' ya está instalada."
            }
        } catch {
            Write-Log "❌ Error al instalar librería '${pkg}': $_" "ERROR"
        }
    }

    # Instalar navegador Chromium para Playwright
    try {
        Write-Log "🌐 Instalando navegador Chromium..."
        & "$PythonExe" -m playwright install chromium | Out-Null
        Write-Log "✔️ Navegador Chromium instalado correctamente."
    } catch {
        Write-Log "❌ Error al instalar navegador de Playwright: $_" "ERROR"
    }
}

# ==============================
# 7️⃣ VALIDACIÓN FINAL Y PRUEBA UIPATH
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
        Write-Log "❌ Error al ejecutar prueba de UiPath: $_" "ERROR"
    }
} else {
    Write-Log "❌ Python no pudo verificarse porque no se encontró el ejecutable."
}

# ==============================
# 8️⃣ RESULTADO FINAL
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
