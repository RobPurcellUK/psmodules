#=======================
# Update PS help
Write-Output "To check for updated help through proxy, use Update-HelpWithProxyCredentials"
Write-Output "You must be running PS as ADMIN to update help for some system modules"
#=======================

#=======================
#Fun bits
Write-Host
Get-Fortune | Write-CowSay
Write-Host
#=======================

#=======================
#Aliases
New-Alias -Name noteit -Value Write-Note
New-Alias -Name notes -Value Show-Note
#=======================

#=======================
#Git utility functions
. (Resolve-Path ~/Documents/WindowsPowershell/gitutils.ps1)
#=======================

#=======================
#Functions
function AddCommitPushGit {
    Param(
        [Parameter(Mandatory=$true)] [string]$commitMessage
    )

    if ($(isCurrentDirectoryGitRepositoryRoot) -eq $false) {
        Write-Host "Must be in a git repository root to acp"
        return
    }

    git add .
    git commit -m "$commitMessage"
    $push = git push 2>&1
    Write-Host $push

    # Lots of faffing incoming!!
    # git push output is on stderr for failure, which means we need to
    #   navigate the ErrorRecord structure to find the message.
    $pushRetType = $push[0].GetType().Name

    if ($pushRetType -eq "ErrorRecord") {
        $setUpstream = $false
        $setUpstreamCommand = [string]::Empty

        $push |  ForEach-Object {
            $_.Exception.Message.Split("`n") | ForEach-Object {
                if ($_ -match "^fatal: The current branch .* has no upstream branch*") {
                    $setUpstream = $true
                }
                elseif ($_ -match "^*git push --set-upstream*") {
                    $setUpstreamCommand = $_
                }
            }
        }

        if (($setUpstream -eq $true) -and ($setUpstreamCommand.Length -gt 0)) {
            $yn = Read-Host -Prompt "set upstream branch and re-push? [y/n]"

            if ($yn.ToLowerInvariant() -eq 'y') {
                Invoke-Expression $setUpstreamCommand
            }
        }
    }
}

New-Alias -Name acp -Value AddCommitPushGit
#=======================

#=======================
# Prompt stuff

$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)
$userTitle = $CurrentUser.Name
$userIsAdmin = $false
if($principal.IsInRole("Administrators")) {
    $userTitle += " as ADMIN"
    $userIsAdmin = $true
}

function prompt {
    # Window title
    $Host.UI.RawUI.WindowTitle = "PS | " + $userTitle + '@' + [System.Environment]::MachineName

    Write-Host

    # Battery
    $charge = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining

    if((-not [System.String]::IsNullOrEmpty($charge)) -and ($charge -lt 100)) {
        $battColour = "Cyan"

        if($charge -lt 25) {
            $battColour = "Red"
        }

        $battWarning = "$($charge)% "
        Write-Host ($battWarning) -ForegroundColor $battColour -NoNewline
    }

    # Git bits
    if (isCurrentDirectoryGitRepository) {
        $status = gitStatus
        $currentBranch = $status["branch"]
        Write-Host('[') -nonewline -foregroundcolor Yellow

        if ($status["ahead"] -eq $FALSE -and $status["behind"] -eq $FALSE) {
            # We are not ahead of origin
            Write-Host($currentBranch) -nonewline -foregroundcolor Cyan
        } else {
            # We are ahead of or behind origin
            Write-Host($currentBranch) -nonewline -foregroundcolor Red
            if ($status["ahead"] -eq $TRUE) {
                Write-Host("(^$($status["aheadCount"]))") -nonewline -foregroundcolor Red
            }
            else {
                Write-Host("(_$($status["behindCount"]))") -nonewline -foregroundcolor Red
            }
        }

        Write-Host(' +' + $status["added"]) -nonewline -foregroundcolor Yellow
        Write-Host(' ~' + $status["modified"]) -nonewline -foregroundcolor Yellow
        Write-Host(' -' + $status["deleted"]) -nonewline -foregroundcolor Yellow

        if ($status["untracked"] -ne $FALSE) {
            Write-Host(' !') -nonewline -foregroundcolor Yellow
        }

        Write-Host('] ') -nonewline -foregroundcolor Yellow
    }

    # Current dir
    Write-Host "[$(Get-Location)] " -NoNewline -ForegroundColor Gray

    #Prompt
    Write-Host
    return $(if($userIsAdmin){"ADMIN"}) + ">"
}
#=======================
