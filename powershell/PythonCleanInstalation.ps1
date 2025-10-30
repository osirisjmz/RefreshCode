Write-Host "⚙️ Instalando Python 3.11.9 en C:\RPA\Python311 ..." -ForegroundColor Cyan

$installer = "C:\Users\Ocyriz\Downloads\python-3.11.9-amd64.exe"

Start-Process -FilePath $installer -ArgumentList `
  "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_pip=1", `
  "Include_test=0", "Include_doc=0", "Include_launcher=1", `
  "Include_tcltk=1", "Include_tools=1", "TargetDir=C:\RPA\Python311" `
  -Wait -PassThru

Write-Host "✅ Instalación completada. Verificando..." -ForegroundColor Green
python --version
