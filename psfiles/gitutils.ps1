# Git functions
# Mark Embling (http://www.markembling.info/)
# Amended Rob Purcell

# Is the current directory a git repository/working copy?
function isCurrentDirectoryGitRepository {
    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($NULL -ne $checkIn) {
        $pathToTest = $checkIn.fullname + '/.git'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $FALSE
}

function isCurrentDirectoryGitRepositoryRoot {
    # Don't check parent paths
    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }

    return $FALSE
}

# Get the current branch
function gitBranchName {
    $currentBranch = ''
    git branch | ForEach-Object {
        if ($_ -match "^\* (.*)") {
            $currentBranch += $matches[1]
        }
    }
    return $currentBranch
}

# Extracts status details about the repo
function gitStatus {
    $untracked = $FALSE
    $added = 0
    $modified = 0
    $deleted = 0
    $ahead = $FALSE
    $behind = $FALSE
    $aheadCount = 0
    $behindCount = 0

    $output = git status

    $branchbits = $output[0].Split(' ')
    $branch = $branchbits[$branchbits.length - 1]

    $output | ForEach-Object {
        if ($_ -match "^*ahead of 'origin/.*' by (\d+) commit*") {
            $aheadCount = $matches[1]
            $ahead = $TRUE
        }
        elseif ($_ -match "^*behind 'origin/.*' by (\d+) commit*") {
            $behindCount = $matches[1]
            $behind = $TRUE
        }
        elseif ($_ -match "deleted:") {
            $deleted += 1
        }
        elseif (($_ -match "modified:") -or ($_ -match "renamed:")) {
            $modified += 1
        }
        elseif ($_ -match "new file:") {
            $added += 1
        }
        elseif ($_ -match "Untracked files:") {
            $untracked = $TRUE
        }
    }

    return @{"untracked" = $untracked;
             "added" = $added;
             "modified" = $modified;
             "deleted" = $deleted;
             "ahead" = $ahead;
             "behind" = $behind;
             "aheadCount" = $aheadCount;
             "behindCount" = $behindCount;
             "branch" = $branch}
}
