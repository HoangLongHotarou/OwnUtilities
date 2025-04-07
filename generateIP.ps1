# Read from file
$input = Get-Content -Path "subnet.txt" -First 1
$subnet, $mask = $input.Split(',')

# Convert IPs to integers
$net = [int[]]$subnet.Split('.') | % { $sum = 0 } { $sum = ($sum * 256) + $_ } { $sum }
$maskInt = [int[]]$mask.Split('.') | % { $sum = 0 } { $sum = ($sum * 256) + $_ } { $sum }

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
