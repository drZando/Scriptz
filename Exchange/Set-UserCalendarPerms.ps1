##########################################################################################################
# Set-UserCalendarPerms.ps1 
# 
# Author: Z
##########################################################################################################
# Powershell Script um Berechtigungen des Kalender sämtlicher UserMailboxen anzupassen
#
# Dieses Script setzt in sämtlichen UserMailboxen, im standard Kalender, die Berechtigungen für
# 'Default', 'Anonymous' und der definierten AD Gruppe.
# 'Default' und 'Anonymous' erhalten die Berechtigung 'None' und die AD Gruppe erhält die Berechtigung 'LimitedDetails'.
##########################################################################################################
# Release Notes:
# 1.1 - 26.07.2019: Verbindig zum Exchange via PSSession anstatt RemoteExchange.ps1 
# 1.0 - 03.04.2019: Initialer Release
##########################################################################################################
$fqdnMailboxServer = "MB-SERVER.domain.tld"
$NameKalaenderRaechtADGruppe = "US_PR_XC_Benutzer-Kalender-Rechte_Alle_MSE_LD"

#------- Nütme alänge ------------------------------------------------------------------------------------
$Session = New-PSSession -ConnectionURI "http://$fqdnMailboxServer/powershell?serializationLevel=Full" -ConfigurationName Microsoft.Exchange
Import-PSSession $Session
Import-Module -Name ActiveDirectory

$MitglidrKalaenderRaechtADGruppe = Get-ADGroupMember $NameKalaenderRaechtADGruppe
$AuiBnutzerPostfaecher = Get-mailbox * | Where-Object{$_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'UserMailbox'}

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
    
    $KalaenderName = Get-MailboxFolderStatistics -FolderScope calendar -Identity $mb.SamAccountName | Where-Object{$_.FolderType -eq "Calendar"} | select Name
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

    if(Get-MailboxFolderPermission -Identity $KalaenderPfad -User anonymous -ErrorAction SilentlyContinue){
        Set-MailboxFolderPermission -Identity $KalaenderPfad -User anonymous -AccessRights None
    }
    else{
        Add-MailboxFolderPermission -Identity $KalaenderPfad -User anonymous -AccessRights None
    }
}
Remove-PSSession $Session