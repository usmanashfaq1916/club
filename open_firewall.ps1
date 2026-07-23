New-NetFirewallRule -DisplayName "Django Dev 8000" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
Write-Host "Firewall rule created. Phone should now reach the backend."
