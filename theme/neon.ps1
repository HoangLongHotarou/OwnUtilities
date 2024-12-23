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

function prompt {
    # Define colors using ANSI escape codes
    $usernameColor = "`e[1;36m"  # Bright Cyan
    $pathColor = "`e[1;33m"      # Bright Yellow
    $branchColor = "`e[1;32m"    # Bright Green (for Git branch)
    $resetColor = "`e[0m"        # Reset

    # Get the username and hostname
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME

    # Get the current working directory
    $currentDir = (Get-Location).Path

    # Extract the last part of the path (brief path)
    $briefPath = Split-Path -Leaf $currentDir

    # Check if the current directory is a Git repository and get the branch name
    $gitBranch = ""
    if (Test-Path ".git") {
        # Get the current Git branch name
        $gitBranch = & git rev-parse --abbrev-ref HEAD
        $gitBranch = "$branchColor($gitBranch)$resetColor"
    }

    # Format the prompt with Git branch if available
    "$usernameColor[$username@$hostname $pathColor$briefPath $gitBranch]`n$ $resetColor"
}
