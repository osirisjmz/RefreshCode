Write-Host "🔧 Limpiando rastros de Python 3.11..." -ForegroundColor Cyan

# Cerrar cualquier proceso Python
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force

# Rutas comunes de Python
$paths = @(
  "C:\Users\Ocyriz\AppData\Local\Programs\Python\Python311",
  "C:\Program Files\Python311",
  "C:\Program Files (x86)\Python311"
)

foreach ($p in $paths) {
  if (Test-Path $p) {
    Write-Host "🧹 Eliminando carpeta: $p"
    Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# Limpiar registro del instalador
$keys = @(
  "HKCU:\Software\Python",
  "HKLM:\Software\Python",
  "HKLM:\Software\Wow6432Node\Python"
)
foreach ($k in $keys) {
  if (Test-Path $k) {
    Write-Host "🧩 Eliminando clave de registro: $k"
    Remove-Item -Path $k -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# Borrar cachés del instalador
Remove-Item -Path "$env:LOCALAPPDATA\Package Cache" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Temp\Python*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✅ Limpieza completada. Python 3.11 completamente eliminado." -ForegroundColor Green
