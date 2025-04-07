# Function to convert IP to integer
function Convert-IPtoInt {
    param ([string]$ip)
    $octets = $ip.Split('.')
    return ([int]$octets[0] * 16777216) + ([int]$octets[1] * 65536) + ([int]$octets[2] * 256) + [int]$octets[3]
}

# Function to convert integer to IP
function Convert-InttoIP {
    param ([int]$int)
    $octet1 = [math]::Floor($int / 16777216)
    $octet2 = [math]::Floor(($int %Rit -shr 24) % 256
    $octet3 = [math]::Floor(($int % 65536) / 256)
    $octet4 = $int % 256
    return "$octet1.$octet2.$octet3.$octet4"
}

# Function to convert mask to CIDR bits
function Convert-MasktoCIDR {
    param ([string]$mask)
    $bits = 0
    $octets = $mask.Split('.')
    foreach ($octet in $octets) {
        $octetVal = [int]$octet
        while ($octetVal -gt 0) {
            $bits += $octetVal -band 1
            $octetVal = $octetVal -shr 1
        }
    }
    return $bits
}

# Get input
Write-Host "Simple IP Generator"
$input = Read-Host "Enter subnet and mask (e.g., 192.168.1.0,255.255.255.0)"

# Split input into subnet and mask
$subnet, $mask = $input.Split(',')

# Calculate range
$networkInt = Convert-IPtoInt $subnet
$maskBits = Convert-MasktoCIDR $mask
$numHosts = [math]::Pow(2, (32 - $maskBits))
$firstIP = $networkInt + 1
$lastIP = $networkInt + $numHosts - 2

# Print usable IPs
Write-Host "`nUsable IP addresses:"
for ($i = $firstIP; $i -le $lastIP; $i++) {
    Write-Host (Convert-InttoIP $i)
}
