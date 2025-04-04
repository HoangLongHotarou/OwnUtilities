# Function to convert IP to integer
function ConvertTo-IntIP {
    param ([string]$ip)
    $octets = $ip.Split(".")
    return ([int]$octets[0] * 16777216) + ([int]$octets[1] * 65536) + ([int]$octets[2] * 256) + ([int]$octets[3])
}

# Check if files exist
if (-not (Test-Path "ip")) { Write-Error "File 'ip' not found"; exit 1 }
if (-not (Test-Path "subnet")) { Write-Error "File 'subnet' not found"; exit 1 }

# Clean up previous splits and results
Remove-Item -Recurse -Force "ip_split", "subnet_split", "results" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "ip_split", "subnet_split", "results" | Out-Null

# Split files
Get-Content "ip" | Group-Object -Property { [math]::Floor([array]::IndexOf((Get-Content "ip"), $_) / 50) } | ForEach-Object {
    $_.Group | Out-File "ip_split/ip_part_$($_.Name).txt"
}
Get-Content "subnet" | Group-Object -Property { [math]::Floor([array]::IndexOf((Get-Content "subnet"), $_) / 50) } | ForEach-Object {
    $_.Group | Out-File "subnet_split/subnet_part_$($_.Name).txt"
}

# Script block for parallel execution
$checkScript = {
    param ($ipFile, $subnetFile, $resultDir)
    $ips = Get-Content $ipFile
    $subnets = Get-Content $subnetFile
    $resultFile = Join-Path $resultDir "result_$($ipFile.BaseName)_$($subnetFile.BaseName).txt"
    
    $notInSubnet = foreach ($ip in $ips) {
        if (-not $ip) { continue }
        $ipInt = ConvertTo-IntIP $ip
        $inSubnet = $false
        foreach ($subnetLine in $subnets) {
            if (-not $subnetLine) { continue }
            $subnet, $netmask = $subnetLine.Split()
            $subnetInt = ConvertTo-IntIP $subnet
            $maskInt = ConvertTo-IntIP $netmask
            $network = $subnetInt -band $maskInt
            $broadcast = $network + (-bnot $maskInt -band 0xFFFFFFFF)
            if ($ipInt -ge $network -and $ipInt -le $broadcast) {
                $inSubnet = $true
                break
            }
        }
        if (-not $inSubnet) { $ip }
    }
    if ($notInSubnet) { $notInSubnet | Out-File $resultFile }
}

# Run jobs in parallel
$jobs = @()
foreach ($ipChunk in Get-ChildItem "ip_split/ip_part_*.txt") {
    foreach ($subnetChunk in Get-ChildItem "subnet_split/subnet_part_*.txt") {
        $jobs += Start-Job -ScriptBlock $checkScript -ArgumentList $ipChunk.FullName, $subnetChunk.FullName, (Resolve-Path "results").Path
    }
}

# Wait for all jobs to complete
$jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

# Combine results
Write-Host "IPs not in any subnet:"
$allIps = Get-Content "ip" | Sort-Object -Unique
$notInSubnet = Get-ChildItem "results/result_*.txt" | Get-Content | Sort-Object -Unique
if ($notInSubnet) {
    Compare-Object $allIps $notInSubnet -IncludeEqual  -PassThru | Where-Object { $_.SideIndicator -eq "<=" } | Sort-Object -Unique
} else {
    $allIps
}

# Cleanup
Remove-Item -Recurse -Force "ip_split", "subnet_split", "results"
Write-Host "Check complete"
