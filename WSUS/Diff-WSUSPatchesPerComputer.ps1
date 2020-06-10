<#  
    .SYNOPSIS  
        Verglicht d'Patches vo 2 Computer und lischtet d'ungerschide uf.
        
    .DESCRIPTION
        Verglicht d'Patches vo 2 Computer und lischtet d'ungerschide uf.        
    
	.PARAMETER WSUSServerName
        FQDN vom WSUS Server
        
    .PARAMETER WSUSServerPort
        Port Nummere vom WSUS Server   
    
	.PARAMETER RechnerA
        Rächnername - die einti Site vom Verglich
        
    .PARAMETER RechnerB
        Rächnername - die angeri Site vom Verglich
        
	.NOTES  
        Name: Z-Diff-WSUSPatchesPerComputer
        Author: Zando
        DateCreated: 21FEB2017 
               
    .LINK  
        https://ps.zandonien.net
        
    .EXAMPLE  
    Z-Diff-WSUSPatchesPerComputer -RechnerA COMPUTERNAME9876 -RechnerB COMPUTERNAME1234

    Description
    -----------
    Vergliecht die fählende Patches, wo bim einte oder angere Rächner fähle

    Result
    ------
    3172605 fäut ufem COMPUTERNAME9876
    3179573 fäut ufem COMPUTERNAME9876
    3185278 fäut ufem COMPUTERNAME1234

           
    #>

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
    $RechnerA,
    
    [Parameter(Mandatory=$true)]
    [string]
    $RechnerB
  
		    
)

if(-not (Get-Module -Name PoshWSUS)) {Import-Module -Name PoshWSUS -ErrorAction 'Stop' -Verbose:$false}
if(-not (Get-PSWSUSServer)) {Connect-PSWSUSServer -WsusServer $WSUSServerName -port $WSUSServerPort}

# gibmer aui Patches vom Normalo Rächner wo: Applicable si und nid Installiert und nid Approved
$auesNoetige_RechnerA = Get-PSWSUSUpdatePerClient -ComputerName $RechnerA | Where-Object {$_.UpdateInstallationState -ne "NotApplicable" -and $_.UpdateInstallationState -ne "Installed" -and $_.UpdateApprovalAction -eq "NotApproved"}
$auesNoetige_RechnerB = Get-PSWSUSUpdatePerClient -ComputerName $RechnerB | Where-Object {$_.UpdateInstallationState -ne "NotApplicable" -and $_.UpdateInstallationState -ne "Installed" -and $_.UpdateApprovalAction -eq "NotApproved"}

$ungerschied = Compare-Object -ReferenceObject $auesNoetige_RechnerA -DifferenceObject $auesNoetige_RechnerB -Property UpdateKB

foreach($u in $ungerschied){
    Switch ($u.SideIndicator)
        {
            "<=" { Write-Host $u.UpdateKB "fäut ufem $RechnerA"; break }
            "=>" { Write-Host $u.UpdateKB "fäut ufem $RechnerB"; break }
        }
}

$azau_RechnerA = ($t=$ungerschied | Where-Object{$_.SideIndicator -eq "<="}).count
$azau_RechnerB = ($t=$ungerschied | Where-Object{$_.SideIndicator -eq "=>"}).count
Write-Host "ufem $RechnerA fähle $azau_RechnerA Patches"
Write-Host "ufem $Rechnerb fähle $azau_Rechnerb Patches"