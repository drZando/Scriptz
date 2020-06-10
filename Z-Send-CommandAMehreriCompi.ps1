[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]
    $Scope,

    [Parameter(Mandatory=$true)]
    [string]
    $Befaeu
)

switch ($Scope)
{
    "desktops" {$Computers = (Get-ADComputer -Filter * | Where-Object{$_.name -match "DMSZUWP"}).name}
    "laptops" {$Computers = (Get-ADComputer -Filter * | Where-Object{$_.name -match "LMSZUWP"}).name}
    "auiclients" {$Computers = (Get-ADComputer -Filter * | Where-Object{$_.name -match "DMSZUWP" -or $_.name -match "LMSZUWP"}).name}
    "servers" {$Computers = (Get-ADComputer -Filter * | Where-Object{$_.name -match "SMSZUW"}).name}
    default {Write-Warning "Das Scope könni nid! es gid desktops/laptops/servers und auiclients"; exit}
}

workflow Test-LouftdChischte {
  param(
    [string[]]$Computers,

    [string[]]$Befaeu

  )

    foreach -parallel ($Hostname in $Computers)
    {
        if(Test-Connection -Count 1 -ComputerName $Hostname -Quiet)
        {
            InlineScript {
                $ScriptblockBefaeu = [Scriptblock]::Create($using:Befaeu)
                Invoke-Command -ComputerName $using:Hostname -ScriptBlock $ScriptblockBefaeu
                Write-Host "###--> Ha am $using:Hostname '$ScriptblockBefaeu' gschickt"
            }
        }
    }

}

Test-LouftdChischte -Computers $Computers -Befaeu $Befaeu