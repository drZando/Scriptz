<#  
    .SYNOPSIS  
        Setzt dr Status vomne benötigte Patch (benötigt anhand vom g'nannte Rächner), ir g'nannte Gruppe, uf Install, sofärn dr Patch ir Queu-Gruppe ou uf Install steid.
        
    .DESCRIPTION
        Setzt dr Status vomne benötigte Patch (benötigt anhand vom g'nannte Rächner), ir g'nannte Gruppe, uf Install, sofärn dr Patch ir Queu-Gruppe ou uf Install steid.        
    
	.PARAMETER WSUSServerName
        FQDN vom WSUS Server
        
    .PARAMETER WSUSServerPort
        Port Nummere vom WSUS Server   
    
	.PARAMETER UpdatePerDaemRaechner
        Rächner wo d'Patches fähle
        
    .PARAMETER QueuueGruppe
        Gruppe wo gäge, die benötigte Patches, Prüeft wärde
        
    .PARAMETER ZiuGruppe
        Gruppe wo d'Patches approved bechund
    
	.PARAMETER ZiuGruppe
        Gruppe wo d'Patches approved bechund
	
	.PARAMETER TaegBisDeadline
		I sovüu Täg isch Deadline
    
	.PARAMETER NumeReport
		Nume ufzeue, nid APPROVE
	
	.NOTES  
        Name: Z-Approve-WSUSPerGruppe
        Author: Zando
        DateCreated: 31Dez2015 
               
    .LINK  
        https://ps.zandonien.net
        
    .EXAMPLE  
    Z-Approve-WSUSPerGruppe.ps1 -QueuueGruppe Alpha-Tester-Gruppe -ZiuGruppe Beta-Tester-Gruppe -UpdatePerDaemRaechner computer01 -NumeReport $true

    Description
    ----------- 
    Lischtet aui Patches uf, wo dr Rächner "computer01" brucht und wo ir "Alpha-Tester-Gruppe" approved si, nid aber ir "Beta-Tester-Gruppe".
    Wär dr Parameter "-NumeReport" uf $false, würde die Patches ir Beta-Tester-Gruppe füre, Install, freigä wärde.

               
    #>

[CmdletBinding()]
Param(
    [Parameter()]
    [string]
    $WSUSServerName = "wsusserver01.fq.dm",
    
    [Parameter()]
    [string]
    $WSUSServerPort = "8530",
    
    [Parameter(Mandatory=$true)]
    [string]
    $UpdatePerDaemRaechner,
  
    [Parameter(Mandatory=$true)]
    [string]
    $QueuueGruppe,
	    
    [Parameter(Mandatory=$true)]
    [string]
    $ZiuGruppe,
		    
    [Parameter(Mandatory=$true)]
    [int]
    $TaegBisDeadline,

    [Parameter(Mandatory=$true)]
    [bool]
    $NumeReport
)

if(-not (Get-Module -Name PoshWSUS)) {Import-Module -Name PoshWSUS -ErrorAction 'Stop' -Verbose:$false}
if(-not (Get-PSWSUSServer)) {Connect-PSWSUSServer -WsusServer $WSUSServerName -port $WSUSServerPort}

$Deadline = (Get-Date).AddDays($TaegBisDeadline)
$typ_ZiuGruppe = Get-PSWSUSGroup -Name $ZiuGruppe

# gibmer aui Patches vom Normalo Rächner wo: Applicable si und nid Installiert und nid Approved
$auesNoetige = Get-PSWSUSUpdatePerClient -ComputerName $UpdatePerDaemRaechner | Where-Object {$_.UpdateInstallationState -ne "NotApplicable" -and $_.UpdateInstallationState -ne "Installed" -and $_.UpdateApprovalAction -eq "NotApproved"}

$t = $auesNoetige.count
$i = 1
$Approve_Parameter = @{Action = "Install"; Group = $typ_ZiuGruppe}
if($TaegBisDeadline -ne 0){$Approve_Parameter.Add("Deadline", $Deadline)}
foreach($update in $auesNoetige){
    $e = Get-PSWSUSUpdateApproval -Update $update.UpdateKB
    if($e.TargetGroup -eq $QueuueGruppe){
        # Aui Patches Approve wo ir Queu-Gruppe scho si approved worde, plus eventuell no e Deadline druf
        if(-not ($NumeReport)){
            Get-PSWSUSUpdate -Update $update.UpdateKB | Where-Object{$_.UpdateID -eq $update.UpdateId} | Approve-PSWSUSUpdate @Approve_Parameter
            Write-Host "Approved für Install ->   " $update.UpdateTitle
        }
        Write-Host $i"/"$t $update.UpdateTitle
        $i++
    }
}
 