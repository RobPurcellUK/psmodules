<#
.Synopsis
   Update the Powershell help, using the default network credentials for the proxy.
.DESCRIPTION
   Update the Powershell help, forcing use of the default system proxy. Sets the proxy credentials on an instance
   of System.Net.WebClient, which then causes all instances of that class in the same AppDomain to use those
   proxy credentials by default.
.EXAMPLE
   Update-HelpWithProxy
   Just run it instead of Update-Help
#>
function Update-HelpWithProxyCredentials {
    Set-UseSystemProxy
    Update-Help -UseDefaultCredentials
}
