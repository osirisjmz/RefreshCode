# ============================================================
# Fix-PythonPath.ps1
# Corrige la ruta de Python en todos los archivos XAML de un proyecto UiPath
# Autor: Osiris Jimenez
# ============================================================

Write-Host "🔍 Iniciando revisión de archivos UiPath (.xaml)..." -ForegroundColor Cyan

# Ruta del proyecto (donde está este script)
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Rutas antiguas y nuevas
$oldPath = 'C:\\Python314\\python.exe'
$newPath = 'C:\\Users\\Ocyriz\\AppData\\Local\\Programs\\Python\\Python311\\python.exe'

# Buscar todos los archivos XAML del proyecto
$xamls = Get-ChildItem -Path $projectPath -Recurse -Filter *.xaml

if ($xamls.Count -eq 0) {
    Write-Host "⚠️ No se encontraron archivos XAML en la ruta: $projectPath" -ForegroundColor Yellow
    exit
}

foreach ($file in $xamls) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match [regex]::Escape($oldPath)) {
        Write-Host "🛠️ Corrigiendo ruta en: $($file.FullName)" -ForegroundColor Green
        $content = $content -replace [regex]::Escape($oldPath), [regex]::Escape($newPath)
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    }
}

Write-Host "`n✅ Reemplazo completado exitosamente." -ForegroundColor Cyan
Write-Host "Rutas actualizadas de '$oldPath' a '$newPath' en todos los XAML." -ForegroundColor White
Write-Host "💡 Ahora puedes abrir el proyecto en UiPath Studio y ejecutar el flujo nuevamente." -ForegroundColor Green
# ============================================================
