##########################################################################################################
# Set-MailboxQuota.ps1
# 
# Author: Z
##########################################################################################################
# Powershell Script um die Quotas der Postfächer zu setzten
#
# Dieses Script geht durch die entsprechenden Gruppen im Active Directory
# und konfiguriert dementsprechend die Quotas der Postfächer.
##########################################################################################################
# Release Notes:
# 1.2 - 26.07.2019: Verbindig zum Exchange via PSSession anstatt RemoteExchange.ps1 
# 1.1 - 07.06.2017: Script für Online Archiv Quota integriert
#                    Setzt nur noch Quotas für Postfächer welche in der lokalen MB-Datenbank liegen
# 1.0 - 06.01.2017: Initialer Release
##########################################################################################################
$fqdnMailboxServer = "MB-SERVER.domain.tld"
$Pre_MBADG_String = "GS_PR_XC-Mailbox-Quota-*_NZ"
$Pre_OAADG_String = "GS_PR_XC-Online-Archiv-Quota-*_NZ"
$MB_Quota_Warning_sub = 0.05GB
$OA_Quota_Warning_sub = 0.5GB

#------- Nütme alänge ------------------------------------------------------------------------------------
Import-Module ActiveDirectory
$AD_MB_Gruppene = Get-ADGroup -Filter "Name -like '$Pre_MBADG_String'"
$AD_OA_Gruppene = Get-ADGroup -Filter "Name -like '$Pre_OAADG_String'"

$Session = New-PSSession -ConnectionURI "http://$fqdnMailboxServer/powershell?serializationLevel=Full" -ConfigurationName Microsoft.Exchange
Import-PSSession $Session


$z = $null
foreach ($z in $AD_MB_Gruppene) {
    $MB_Quota = (($z.name.Substring($Pre_MBADG_String.Length - 4).substring(0, ($z.name.Substring($Pre_MBADG_String.Length - 4)).length - 3))).tostring()
    
    $u = $null
    foreach ($u in Get-ADGroupMember $z.Name) {
        $MB_Quota_ProhibitSendReceive = $MB_Quota
        $MB_Quota_ProhibitSend = $MB_Quota_ProhibitSendReceive - $MB_Quota_Warning_sub
        $MB_Quota_ProhibitSend = [math]::Round($MB_Quota_ProhibitSend)
        $MB_Quota_Warning = $MB_Quota_ProhibitSend - $MB_Quota_Warning_sub
        $MB_Quota_Warning = [math]::Round($MB_Quota_Warning)
                
        Set-Mailbox -Identity $u.objectGUID.ToString() -IssueWarningQuota $MB_Quota_Warning -ProhibitSendQuota $MB_Quota_ProhibitSend -ProhibitSendReceiveQuota $MB_Quota_ProhibitSendReceive -UseDatabaseQuotaDefaults $false
    }
}

$z = $null
foreach ($z in $AD_OA_Gruppene) {
    $OA_Quota = (($z.name.Substring($Pre_OAADG_String.Length - 4).substring(0, ($z.name.Substring($Pre_OAADG_String.Length - 4)).length - 3))).tostring()
    
    $u = $null
    foreach ($u in Get-ADGroupMember $z.Name) {
        if (ischer-ir-lokale-MDB $u.SamAccountName) {
            $OA_Quota_Warning = $OA_Quota - $OA_Quota_Warning_sub

            Set-Mailbox -Identity $u.objectGUID.ToString() -ArchiveQuota $OA_Quota -ArchiveWarningQuota $OA_Quota_Warning
        }
    }
}
Remove-PSSession $Session