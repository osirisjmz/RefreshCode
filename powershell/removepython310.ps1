<#
.SYNOPSIS
    Desinstala completamente Python 3.10 del sistema:
    - Elimina carpetas residuales (C:\RPA\Python310, AppData, Program Files)
    - Quita rutas de PATH
    - Elimina claves del registro asociadas a Python 3.10
    - Limpia launchers obsoletos (playwright.exe, pip.exe, etc.)
#>

Write-Host "🚀 Iniciando limpieza completa de Python 3.10..." -ForegroundColor Cyan

# 1️⃣ Rutas comunes
$Paths = @(
    "C:\RPA\Python310",
    "$env:LOCALAPPDATA\Programs\Python\Python310",
    "$env:ProgramFiles\Python310",
    "$env:APPDATA\Python\Python310",
    "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3.10_qbz5n2kfra8p0"
)

# 2️⃣ Claves de registro
$RegKeys = @(
    "HKCU:\Software\Python\PythonCore\3.10",
    "HKLM:\SOFTWARE\Python\PythonCore\3.10",
    "HKLM:\SOFTWARE\WOW6432Node\Python\PythonCore\3.10"
)

# 3️⃣ Eliminar carpetas
foreach ($p in $Paths) {
    if (Test-Path $p) {
        try {
            Write-Host "🧹 Eliminando carpeta: $p"
            Remove-Item -Recurse -Force $p
        } catch { Write-Host "⚠️ No se pudo eliminar $p — $_" -ForegroundColor Yellow }
    }
}

# 4️⃣ Eliminar claves de registro
foreach ($r in $RegKeys) {
    if (Test-Path $r) {
        try {
            Write-Host "🧹 Eliminando clave de registro: $r"
            Remove-Item -Recurse -Force $r
        } catch { Write-Host "⚠️ No se pudo eliminar clave $r — $_" -ForegroundColor Yellow }
    }
}

# 5️⃣ Quitar referencias del PATH (Usuario y Sistema)
function Remove-FromPath {
    param($Scope)
    $path = [System.Environment]::GetEnvironmentVariable("Path", $Scope)
    if ($null -ne $path) {
        $cleanPath = ($path -split ";") | Where-Object { $_ -and ($_ -notmatch "Python310") }
        $newPath = ($cleanPath -join ";")
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, $Scope)
        Write-Host "✅ PATH limpio en ámbito $Scope"
    }
}
Remove-FromPath -Scope "Machine"
Remove-FromPath -Scope "User"

# 6️⃣ Eliminar posibles launchers huérfanos
$LauncherPaths = @(
    "$env:LOCALAPPDATA\Programs\Python\Launcher",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps",
    "$env:ProgramFiles\Python Launcher"
)
foreach ($lp in $LauncherPaths) {
    Get-ChildItem -Path $lp -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "3\.10" -or $_.Name -match "python.*\.exe" } |
        ForEach-Object {
            try {
                Write-Host "🗑️ Eliminando launcher: $($_.FullName)"
                Remove-Item $_.FullName -Force
            } catch {}
        }
}

Write-Host "✅ Limpieza completada. Reinicia PowerShell o el sistema para aplicar los cambios." -ForegroundColor Green
