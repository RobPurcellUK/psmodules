<#
.Synopsis
   Simple note-taking from the PS command-line.
.DESCRIPTION
   Write a plain text note to the ~/Documents/Notes directory, in a dated file.
.EXAMPLE
   Write-Note Using complicated CLI: dothething.exe -ne -r ouou --bigparam 'thing here'
   Write-Note Important URL http://thisisthesite.orc/page/readmenow
#>
function Write-Note {
    Param(
        [Parameter(Mandatory=$true)] [string]$data
    )

    Set-Variable notesPath ~\Documents\Notes

    if(-not (Test-Path -LiteralPath $notesPath))
    {
        Write-Output "Creating notes directory $($notesPath)"
        New-Item $notesPath -ItemType Directory
    }

    Set-Variable curdate $(get-date -format yyyy-MM-dd)
    Set-Variable curdatetime $(get-date -format 'yyyy-MM-dd HH:mm:ss')
    Set-Variable title $notesPath\$curdate.txt

    if(Test-Path -LiteralPath $title) {
        #Write-Output $curdatetime >> $title
        Write-Output $data >> $title
        Write-Output "note appended at $title"
    }
    else {
        Write-Output $curdatetime > $title
        Write-Output $data >> $title
        Write-Output "note created at $title"
    }
}

function Show-Note {
    Set-Variable notesPath ~/Documents/Notes

    if(-not (Test-Path -LiteralPath $notesPath))
    {
        Write-Output "No note directory ($($notesPath)) means no notes have been created."
    }

    Start-Process (Resolve-Path $notesPath)
}
