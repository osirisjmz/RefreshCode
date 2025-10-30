$pythonPath = "C:\RPA\Python311"
$scriptPath = "$pythonPath\Scripts"

# Agrega ambas rutas al PATH del sistema
[System.Environment]::SetEnvironmentVariable(
    "Path",
    [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";$pythonPath;$scriptPath",
    "Machine"
)

Write-Host "✅ Se agregaron las rutas al PATH del sistema:`n$pythonPath`n$scriptPath"
