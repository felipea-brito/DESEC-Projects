param($ip)

if (!$ip) {
    Write-Output "Example of use: .\file.ps1 192.168.0.1"
    return
}

do {
    $modo = Read-Host "Scan initial 1024 ports or all? Type 1 or 2"
} until ($modo -eq 1 -or $modo -eq 2)

$range = if ($modo -eq 1) { 1..1024 } else { 1..65535 }

foreach ($port in $range) {
    if (Test-NetConnection $ip -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet) {
        Write-Output "Port $port Open"
    } else {
        Write-Output "Port $port Closed"
    }
}
