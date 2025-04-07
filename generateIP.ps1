# Read from file (PowerShell 7 compatible)
$input = Get-Content -Path "subnet.txt" -TotalCount 1
$subnet, $mask = $input -split ','

# Convert IPs to integers
$net = [int[]]($subnet -split '\.') | ForEach-Object -Begin { $sum = 0 } -Process { $sum = ($sum * 256) + $_ } -End { $sum }
$maskInt = [int[]]($mask -split '\.') | ForEach-Object -Begin { $sum = 0 } -Process { $sum = ($sum * 256) + $_ } -End { $sum }

# Calculate range
$hostBits = [math]::Log(($maskInt -bxor 0xFFFFFFFF) + 1, 2)
$firstIP = $net + 1
$lastIP = $net + [math]::Pow(2, $hostBits) - 2

# Output IPs
Write-Host "`nUsable IPs from $input:"
for ($i = $firstIP; $i -le $lastIP; $i++) {
    $ip = [bitconverter]::GetBytes([uint32]$i)[3..0] -join '.'
    Write-Host $ip
}
