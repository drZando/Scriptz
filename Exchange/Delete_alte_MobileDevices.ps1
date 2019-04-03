##########################################################################################################
# Delete_alte_MobileDevices.ps1 
# 
# Author: Z
# Datum: 05.06.2018
# Version: 1.1
##########################################################################################################
# Beschreibung:
# Powershell Script um alle Mobile Devices zu löschen, welche länger als X-Tage nicht
# erfolgreich Synchronisiert haben
##########################################################################################################
# Vorkehrungen:
##########################################################################################################
# Ufruef:
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive -WindowStyle Hidden -command ". 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto;  C:\Scripts\Exchange\Delete_alte_MobileDevices.ps1
##########################################################################################################
# Release Notes:
# V1.1 - 05.06.2018: Update für Logfile und Bugfix (Ohni LastSuccessSync si nie glösche worde)
# V1.0 - 26.04.2017: Initialer Release
##########################################################################################################

$Jetz = Get-Date -Format yyyy.MM.dd_HH:mm
$gnadefrischt = -45 #in Täg, sid am letschtemou erfougrich sync. Negativ wüu ir Vergangeheit
$Log = "C:\log\Delete_alte_MobileDevices.log"

$denne = (Get-Date).AddDays($gnadefrischt).ToString('dd.MM.yyyy hh:mm:ss')
$aui_graetli = Get-MobileDevice

foreach($h in $aui_graetli){
    $sync_status = Get-MobileDeviceStatistics $h
    $z = $sync_status.LastSuccessSync

    if(!$z){
        Remove-MobileDevice ($h.Identity).ToString() -Confirm:$false
        Add-Content -Path $Log -Value "$($Jetz);DELETE-Ke_LastSuccessSync;$($h.Identity);$($h.FriendlyName);$($h.DeviceUserAgent)"
    }

    if((get-date $denne) -gt (get-date $z)){
        Remove-MobileDevice ($h.Identity).ToString() -Confirm:$false
        Add-Content -Path $Log -Value "$($Jetz);DELETE-LastSuccessSync_zLang;$($h.Identity);$($h.FriendlyName);$($h.DeviceUserAgent)"

    }
}
