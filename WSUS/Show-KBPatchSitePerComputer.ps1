[CmdletBinding()]
Param(
    [Parameter()]
    [string]
    $WSUSServerName = "wsusserver.fq.dn",
    
    [Parameter()]
    [string]
    $WSUSServerPort = "8530",
	
    [Parameter(Mandatory=$true)]
    [string]
    $UpdatePerDaemRaechner
)

if(-not(Get-Module -Name PoshWSUS)) {Import-Module -Name PoshWSUS -ErrorAction 'Stop' -Verbose:$false}
if(-not(Get-PSWSUSServer)) {Connect-PSWSUSServer -WsusServer $WSUSServerName -port $WSUSServerPort}

$ie = New-Object -ComObject InternetExplorer.Application

$Noetigi_Patches = Get-PSWSUSUpdatePerClient -ComputerName $UpdatePerDaemRaechner -UpdateScope (New-PSWSUSUpdateScope -ExcludedInstallationStates Unknown,NotApplicable,Installed -ApprovedStates NotApproved) | Sort-Object UpdateTitle
if($Noetigi_Patches){
    foreach($kb in $Noetigi_Patches){
        $KB_URL = "http://support.microsoft.com/en-us/kb/"+$kb.UpdateKB
        $ie.Navigate($KB_URL, 4096);
    }
    $ie.Visible = $True;
}
else{
    Write-Host "Füre Rächner"$UpdatePerDaemRaechner" gitz keni Patches"
}
