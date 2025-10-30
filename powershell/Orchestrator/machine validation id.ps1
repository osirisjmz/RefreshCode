$response.value | ForEach-Object {
    Write-Host "Name: $($_.Name), Id: $($_.Id)"
}
