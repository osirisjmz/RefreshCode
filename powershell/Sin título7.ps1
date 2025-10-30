New-NetFirewallRule -DisplayName "SQL Server 1433" `
                    -Direction Inbound `
                    -LocalPort 1433 `
                    -Protocol TCP `
                    -Action Allow `
                    -Profile Any
