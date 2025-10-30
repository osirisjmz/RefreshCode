Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Python%'" | ForEach-Object { $_.Uninstall() }
