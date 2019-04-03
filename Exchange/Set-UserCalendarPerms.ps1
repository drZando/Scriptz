##########################################################################################################
# Set-UserCalendarPerms.ps1 
# 
# Author: Z
# Datum: 03.04.2019
# Version: 1.0
##########################################################################################################
# Powershell Script um Berechtigungen des Kalender sämtlicher UserMailboxen anzupassen
#
# Dieses Script setzt in sämtlichen UserMailboxen, im standard Kalender, die Berechtigungen für
# 'Default', 'Anonymous' und der definierten AD Gruppe.
# 'Default' und 'Anonymous' erhalten die Berechtigung 'None' und die AD Gruppe erhält die Berechtigung 'LimitedDetails'.
##########################################################################################################
# Ufruef
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive -WindowStyle Hidden -command ". 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; C:\Scripts\Exchange\Set-UserCalendarPerms.ps1"
##########################################################################################################
# Release Notes:
# V1.0 - 03.04.2019: Initialer Release
##########################################################################################################

Import-Module -Name ActiveDirectory
$NameKalaenderRaechtADGruppe = "US_PR_XC_Benutzer-Kalender-Rechte_LD"
$MitglidrKalaenderRaechtADGruppe = Get-ADGroupMember $NameKalaenderRaechtADGruppe
$AuiBnutzerPostfaecher = Get-mailbox * | Where-Object{$_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'UserMailbox'}

$AuiBnutzerPostfaecher = Get-Mailbox Z

if((!($MitglidrKalaenderRaechtADGruppe)) -and (!($AuiBnutzerPostfaecher))){
}
elseif($MitglidrKalaenderRaechtADGruppe -and $AuiBnutzerPostfaecher){

    $diffADMBs = Compare-Object -ReferenceObject $MitglidrKalaenderRaechtADGruppe.SamAccountName -DifferenceObject $AuiBnutzerPostfaecher.SamAccountName
    
    foreach($u in $diffADMBs){
            switch($u.SideIndicator){
                    "=>" {Add-ADGroupMember -Identity $NameKalaenderRaechtADGruppe -members $u.InputObject}
                    "<=" {Remove-ADGroupMember -Identity $NameKalaenderRaechtADGruppe -members $u.InputObject -Confirm:$false}
            }
    }
}
elseif(!($MitglidrKalaenderRaechtADGruppe)){

    foreach($u in $AuiBnutzerPostfaecher){
        Add-ADGroupMember -Identity $NameKalaenderRaechtADGruppe -members $u.SamAccountName
    } 
}
elseif(!($AuiBnutzerPostfaecher)){

    foreach($u in $MitglidrKalaenderRaechtADGruppe){
        Remove-ADGroupMember -Identity $NameKalaenderRaechtADGruppe -members $u.SamAccountName -Confirm:$false
    }
}

foreach($mb in $AuiBnutzerPostfaecher){
    
    $KalaenderName = Get-MailboxFolderStatistics -FolderScope calendar -Identity $mb.SamAccountName | Where-Object{$_.FolderType -eq "Calendar"} | Select-Object Name
    $KalaenderPfad = $mb.SamAccountName +":\"+ $KalaenderName.Name

    if(Get-MailboxFolderPermission -Identity $KalaenderPfad -User $NameKalaenderRaechtADGruppe -ErrorAction SilentlyContinue){
        Set-MailboxFolderPermission -Identity $KalaenderPfad -User $NameKalaenderRaechtADGruppe -AccessRights LimitedDetails
    }
    else{
        Add-MailboxFolderPermission -Identity $KalaenderPfad -User $NameKalaenderRaechtADGruppe -AccessRights LimitedDetails
    }

    if(Get-MailboxFolderPermission -Identity $KalaenderPfad -User Default -ErrorAction SilentlyContinue){
        Set-MailboxFolderPermission -Identity $KalaenderPfad -User Default -AccessRights None
    }
    else{
        Add-MailboxFolderPermission -Identity $KalaenderPfad -User Default -AccessRights None
    }

    if(Get-MailboxFolderPermission -Identity $KalaenderPfad -User Anonymous -ErrorAction SilentlyContinue){
        Set-MailboxFolderPermission -Identity $KalaenderPfad -User Anonymous -AccessRights None
    }
    else{
        Add-MailboxFolderPermission -Identity $KalaenderPfad -User Anonymous -AccessRights None
    }
}
