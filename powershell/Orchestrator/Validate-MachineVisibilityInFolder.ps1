# Verifica qué machines están en el folder
Invoke-RestMethod -Uri "https://cloud.uipath.com/$account/$tenant/orchestrator_/odata/Machines" `
  -Headers @{ Authorization = "Bearer $token"; "X-UIPATH-OrganizationUnitId" = 852842 }
