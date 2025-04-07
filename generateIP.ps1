# Define the IP address and subnet mask
$ipAddress = "192.168.1.0"
$subnetMask = "255.255.255.254"

# Convert subnet mask to CIDR notation
$maskBytes = $subnetMask.Split('.') | ForEach-Object { [Convert]::ToString([byte]$_, 2) }
$cidrPrefix = ($maskBytes -join '').IndexOf('0')
if ($cidrPrefix -eq -1) { $cidrPrefix = 32 }

# Calculate network address
$ipBytes = $ipAddress.Split('.') | ForEach-Object { [byte]$_ }
$maskBytes = $subnetMask.Split('.') | ForEach-Object { [byte]$_ }
$networkBytes = @(0, 0, 0, 0)
for ($i = 0; $i -lt 4; $i++) {
    $networkBytes[$i] = $ipBytes[$i] -band $maskBytes[$i]
}
$networkAddress = $networkBytes -join '.'

# Calculate the number of hosts in this subnet
$hostBits = 32 - $cidrPrefix
$hostCount = [Math]::Pow(2, $hostBits)

# Generate all IP addresses in the subnet
$ips = @()
for ($i = 0; $i -lt $hostCount; $i++) {
    $ipBytes = $networkBytes.Clone()
    
    # Apply host bits
    for ($j = 3; $j -ge 0; $j--) {
        $bytePosition = 3 - $j
        $byteValue = [Math]::Floor($i / [Math]::Pow(256, $bytePosition)) % 256
        $ipBytes[$j] = $ipBytes[$j] + $byteValue
    }
    
    $ips += ($ipBytes -join '.')
}

# Output all IP addresses
$ips
