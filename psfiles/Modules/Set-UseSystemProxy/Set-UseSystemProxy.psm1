<#
.Synopsis
   Set the network credentials for proxy access to the default system proxy for the current session.
.DESCRIPTION
   Forcing use of the default system proxy. Sets the proxy credentials on an instance
   of System.Net.WebClient, which then causes all instances of that class in the same AppDomain to use those
   proxy credentials by default.
.EXAMPLE
   Set-UseSystemProxy
#>
function Set-UseSystemProxy {
    $wc = New-Object System.Net.WebClient
    $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
}
