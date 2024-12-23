function prompt {
    # Define colors using ANSI escape codes
    $usernameColor = "`e[1;36m"  # Bright Cyan
    $pathColor = "`e[1;33m"      # Bright Yellow
    $resetColor = "`e[0m"        # Reset

    # Get the username and hostname
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME

    # Get the current working directory
    $currentDir = (Get-Location).Path

    # Extract the last part of the path
    $briefPath = Split-Path -Leaf $currentDir

    # Format the prompt
    "$usernameColor[$username@$hostname $pathColor$briefPath]`n$ $resetColor"
}