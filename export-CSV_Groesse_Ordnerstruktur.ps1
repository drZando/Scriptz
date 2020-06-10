##########################################################################################################
# Export-CSV_Groesse_Ordnerstruktur.ps1 
# 
# Author: Z
# Datum: 18.05.2020
##########################################################################################################
# Beschriebig:
# Powershell Script um d'Ordnergrössi und d'Azau Dateie imne Ordner ufzlischte und aus CSV uszgä.
#
# d'Scanntöifi cha mitgä wärde ou öbs es Log söu mache oder nid.
# ########################################################################################################
# Vorkehrige:
# Damit Ordnerpfäde länger als 260 Zeichen chöi usgläse wärde mues mindistens PS5 loufe und s'OS 
# muess mindestens Windows 10 si.
# 
# Für das bruchts ouno e itrag ir Registrierig, cha aber ou via GPO gsetzt wärde.
# Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -value 1
# GP Lokation:  Configuration > Administrative Templates > System > FileSystem 
##########################################################################################################
# Ufruef
# C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive -WindowStyle hidden -NoProfile -Command "& 'C:\Scripts\Export-CSV_Groesse_Ordnerstruktur.ps1' -LogErstoeue:$true -Root \\Server01\dfs\Folder -ScanToeifi 1 -ReportDateiname Platzverbrauch -ReportDateiOrdner C:\Audits\"
##########################################################################################################
# Release Notes:
# V1.0 - 18.05.2020: Initialer Release
##########################################################################################################

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$Root,

    [Parameter(Mandatory=$True)]
    [int]$ScanToeifi,
    
    [Parameter(Mandatory=$True)]
    [string]$ReportDateiname,

    [Parameter(Mandatory=$True)]
    [string]$ReportDateiOrdner,
    
    [Parameter(Mandatory=$false)]
    [bool]$LogErstoeue = $false
)

if(!($ReportDateiOrdner.EndsWith("\"))){
    $ReportDateiOrdner = $ReportDateiOrdner + "\"
}

if($LogErstoeue){
    $Scriptname = ($MyInvocation.MyCommand.Name) -replace ".{4}$"
    $logdatei = $PSScriptRoot + "\" + $Scriptname + ".log"
    Start-Transcript -LiteralPath $logdatei -Append
}

$Jetz = Get-Date
Write-Host "#-- Start -> $Jetz"
$Datum = $Jetz.ToString("yyyy.MM.dd")
$Zyt = $Jetz.ToString("HH:mm")
$ReportDateiname = $ReportDateiname + "-" + ($Jetz.ToString("yyyyMMdd_HHmm")) + ".csv"
$ExportDateiPfad = $ReportDateiOrdner + $ReportDateiname
$ScanOrdner = (Get-ChildItem -LiteralPath $Root -Depth $ScanToeifi).FullName

<#---- n�tme fingerle ----------------------------------#>

$Ordnerinventar = @()

foreach ($Ordner in $ScanOrdner) {

    Remove-Variable Itrag -ErrorAction SilentlyContinue
        
        if ((Get-Item $Ordner).PSIsContainer) {
        
            #Write-Host "luege jetz in "$Ordner
            $wievueu = Get-ChildItem $Ordner -Recurse | Measure-Object -Property Length -Sum
        
            if ($wievueu) {
            
                $Itrag = [PSCustomObject]@{
                    'Wo'           = $Ordner
                    'Datum'        = $Datum
                    'Zyt'          = $Zyt
                    'AzauDateie'   = $wievueu.Count
                    'Groessi (B)'  = $wievueu.Sum
                    'Groessi (GB)' = $wievueu.Sum / 1GB
                }
            }
            else {

                $Itrag = [PSCustomObject]@{
                    'Wo'           = $Ordner
                    'Datum'        = $Datum
                    'Zyt'          = $Zyt
                    'AzauDateie'   = "0"
                    'Groessi (B)'  = "0"
                    'Groessi (GB)' = "0"
                }
            }
            $Ordnerinventar += $Itrag
        }
}
$Ordnerinventar | Export-Csv $ExportDateiPfad -NoTypeInformation -Encoding UTF8

$Naer = Get-Date
$Wielang = $Naer - $Jetz
Write-Host "#-- Stop -> $Naer"
write-host "#-- Das hed jetz $($Wielang.TotalMinutes) Minute dured"
write-host "#-------------------------------------------------------------------------- "


if($LogErstoeue){Stop-Transcript}
