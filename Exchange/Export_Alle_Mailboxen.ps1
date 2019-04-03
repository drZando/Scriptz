##########################################################################################################
# Export_Alle_Mailbox.ps1 
# 
# Author: Z
# Datum: 10.11.2015
# Version: 1.0
##########################################################################################################
# Beschreibung:
# Powershell Script um sämtliche Postfacher von einem Exchange Server auf einen UNC Pfad zu exportieren
#
# Dieses Script exportiert alle Postfächer der Organisation, auf einen UNC Pfad,
# welche auf einem 2010 XC oder höher liegen.
# Im Anschluss werden sämtliche, als "Completed" markierte Export Requests gelöscht.
##########################################################################################################
# Vorkehrungen:
# Damit ein Konto ein Export durchführen kann, muss diesem die notwendige Berechtigung erteilt werden.
# Entweder man gibt einem bestimmten Benutzer oder Gruppe das Recht.
# In kleineren Umgebungen kann man gleich die bestehende Gruppe 'Organization Management' nehmen.
#
# New-ManagementRoleAssignment -SecurityGroup "Organization Management" -Role "Mailbox Import Export"
##########################################################################################################
# Release Notes:
# V1.0 - 10.11.2015: Initialer Release
##########################################################################################################

$MailboxServer = "MailboxServer01"
$Backup_Ziel_Root_Pfad = "\\BackupServer01\$MailboxServer\Mailboxen\"

add-pssnapin *exchange*
$jetz = Get-Date -Format yyyy.MM.dd

Get-MailboxExportRequest | Where-Object{$_.Status -eq "Completed"} | Remove-MailboxExportRequest -Confirm:$false

Remove-Item $Backup_Ziel_Root_Pfad*.pst -Recurse

$aui_XC2010_und_hoecher_MB = Get-Mailbox -Server $MailboxServer | Where-Object {$_.ExchangeVersion.ExchangeBuild.Major -ge 14}

foreach($User in $aui_XC2010_und_hoecher_MB){
    $Backup_Pfad = $Backup_Ziel_Root_Pfad+$user.SamAccountName+".pst"
    $Backup_Pfad_Archiv = $Backup_Ziel_Root_Pfad+$user.SamAccountName+"-Archiv.pst"
    $MoveName = $jetz + "-" + $user.alias
    $MoveName_Archiv = $jetz + "-" + $user.alias + "-Archiv"
    New-MailboxExportRequest -Name $MoveName -FilePath $Backup_Pfad -Mailbox $user.alias
    if(Get-Mailbox $user.alias -Archive -ErrorAction ignore){New-MailboxExportRequest -Name $MoveName_Archiv -FilePath $Backup_Pfad_Archiv -Mailbox $user.alias -IsArchive}
}
