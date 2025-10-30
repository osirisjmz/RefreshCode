# === CONFIGURACIÓN ===
$CarpetaRaiz = "C:\Users\Ocyriz\Documents\unix"      # Carpeta desde donde se hará la búsqueda
$ArchivoSalida = "C:\Users\Ocyriz\Desktop"  # Ruta completa del archivo de salida

# === FUNCIONALIDAD ===
Get-ChildItem -Path $CarpetaRaiz -Recurse -File | ForEach-Object {
    $_.FullName
} | Out-File -FilePath $ArchivoSalida -Encoding UTF8

Write-Host "Listado de archivos generado en: $ArchivoSalida"
