##########################################################################################################
# Delete-alte_MobileDevices.ps1 
# 
# Author: Z
##########################################################################################################
# Beschreibung:
# Powershell Script um alle Mobile Devices zu löschen, welche länger als X-Tage nicht
# erfolgreich Synchronisiert haben
##########################################################################################################
# Vorkehrungen:
##########################################################################################################
# Release Notes:
# 1.2 - 26.07.2019: Verbindig zum Exchange via PSSession anstatt RemoteExchange.ps1 
# 1.1 - 05.06.2018: Update für Logfile und Bugfix (Ohni LastSuccessSync si nie glösche worde)
# 1.0 - 26.04.2017: Initialer Release
##########################################################################################################
$fqdnMailboxServer = "MB-SERVER.domain.tld"
$gnadefrischt = -45 #in Täg, sid am letschtemou erfougrich sync. Negativ wüu ir Vergangeheit
$Log = "C:\MedS\Scripts\Exchange\Delete-alte_MobileDevices.log"

#------- Nütme alänge ------------------------------------------------------------------------------------
$Session = New-PSSession -ConnectionURI "http://$fqdnMailboxServer/powershell?serializationLevel=Full" -ConfigurationName Microsoft.Exchange
Import-PSSession $Session

$Jetz = Get-Date -Format yyyy.MM.dd_HH:mm
$denne = (Get-Date).AddDays($gnadefrischt).ToString('dd.MM.yyyy hh:mm:ss')
$aui_graetli = Get-MobileDevice

foreach ($h in $aui_graetli) {
    $sync_status = Get-MobileDeviceStatistics $h
    $z = $sync_status.LastSuccessSync

    if (!$z) {
        Remove-MobileDevice ($h.Identity).ToString() -Confirm:$false
        Add-Content -Path $Log -Value "$($Jetz);DELETE-Ke_LastSuccessSync;$($h.Identity);$($h.FriendlyName);$($h.DeviceUserAgent)"
    }

    if ((get-date $denne) -gt (get-date $z)) {
        Remove-MobileDevice ($h.Identity).ToString() -Confirm:$false
        Add-Content -Path $Log -Value "$($Jetz);DELETE-LastSuccessSync_zLang;$($h.Identity);$($h.FriendlyName);$($h.DeviceUserAgent)"

    }
}
