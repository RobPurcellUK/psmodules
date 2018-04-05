<#
.Synopsis
   Prints a random fortune to the console.
.DESCRIPTION
   Prints a random fortune to the console.
   Reads fortunes from fortune.txt in the PS $profile directory, fortunes separated by % in the file.
   Fortunes taken from the Tao of Programming and AI Koans.
.EXAMPLE
   Get-Fortune
#>
function Get-Fortune {
    if(!$PSScriptRoot) {
        $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
    }

    $fortune_file = $PSScriptRoot+'\fortune.txt'

    if(Test-Path $fortune_file) {
        [System.IO.File]::ReadAllText($fortune_file) -replace "`r`n", "`n" -split "`n%`n" | Get-Random
    }
}
