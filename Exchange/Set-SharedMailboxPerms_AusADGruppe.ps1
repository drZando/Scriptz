##########################################################################################################
# Set-SharedMailboxPerms_AusADGruppe.ps1 
# 
# Author: Z
# Datum: 30.05.2017
# Version: 1.0
##########################################################################################################
# Powershell Script um Berechtigungen für Group-Mailbox zu setzten
#
# Dieses Script geht durch die entsprechenden Gruppen im Active Directory
# und setzt die FULLACCESS Berechtigung, für jedes Benutzerkonto, welches Mitglied der Gruppe ist,
# auf die jeweilige Mailbox. Zusätzlich wird jedes Benutzerkonto auch berächtigt "im-Auftrag-von" zu senden
##########################################################################################################
# Ufruef
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive -WindowStyle Hidden -command ". 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; C:\MedS\Scripts\Exchange\Set-MailboxPerms_AusADGruppe.ps1"
##########################################################################################################
# Release Notes:
# V1.0 - 30.05.2017: Initialer Release
##########################################################################################################
# Variable
$MB_Perm_Gruppene = Get-ADGroup -Filter "Name -like 'GS_MX_MB-*_FC'" -Properties *
$trim_pre_grp = "GS_MX_MB-"
$trim_post_grp = "_FC"
$add_pre_usr = "mbo_"
$MB_Srv_XCDatebank = Get-MailboxDatabase -Server $env:COMPUTERNAME | Where-Object{$_.Name -notlike "*archiv*"}
$Tag_nid_automap = "z - nidmappe;"

# Büetz
Import-Module ActiveDirectory

foreach($g in $MB_Perm_Gruppene){
    $MBO_Name = $null
    $Soette_Raecht_ha = $null
    $Hei_Zurzyt_Raecht = $null
    $diff_MB_Raecht = $null
    $diff = $null
    $automap = $true

    $MBO_Name = $add_pre_usr+($g.name -replace $trim_pre_grp -replace $trim_post_grp)
    $MB_Datebank = Get-Mailbox $MBO_Name -ErrorAction SilentlyContinue | select Database
    
    if($g.info){
        if($g.info.ToUpper() -eq $Tag_nid_automap.ToUpper()){$automap = $false}
    }

    #if(($MB_Datebank) -and $MB_Datebank.Database.Name -eq $MB_Srv_XCDatebank.Name){

        $Soette_Raecht_ha = Get-ADGroupMember $g | Get-ADUser

        $bla = Set-Mailbox -Identity $MBO_Name -GrantSendOnBehalfTo (Get-ADGroupMember $g).sAMAccountName

        if(Get-ADUser -Filter {mailNickname -eq $MBO_Name}){
           $Hei_Zurzyt_Raecht = Get-MailboxPermission -Identity $MBO_Name | Where-Object{$_.IsInherited -eq $false -and $_.Deny -eq $false -and $_.User -notlike "NT AUTHORITY\SELF"}
            
            #Es hed Rächt ufem Poschtfach und es hed Rächt ir Gruppe
            if(($Soette_Raecht_ha) -and ($Hei_Zurzyt_Raecht)){
                $diff_MB_Raecht = Compare-Object -ReferenceObject $Soette_Raecht_ha.SID.Value -DifferenceObject $Hei_Zurzyt_Raecht.User.SecurityIdentifier.Value
            
               foreach($diff in $diff_MB_Raecht){

                    $sjohjo=@{Identity=$MBO_Name; User=$diff.InputObject; AccessRights="FullAccess"}
                    if(!($automap)){$sjohjo.add("AutoMapping", $False)}

                   switch($diff.SideIndicator){
                      "=>" {Remove-MailboxPermission -Identity $($MBO_Name) -User $($diff.InputObject) -AccessRights FullAccess -Confirm:$false | Out-Null}
                      #"<=" {Add-MailboxPermission @sjohjo | Out-Null}
                      "<=" {Add-MailboxPermission -Identity $MBO_Name -User $diff.InputObject -AccessRights FullAccess | Out-Null}
                  }
              }
           }
           #Es hed nume Konti ir Gruppe, ufem Poschtfach hetz nüt
            elseif(($Soette_Raecht_ha) -and (!($Hei_Zurzyt_Raecht))){
              foreach($u in $Soette_Raecht_ha){

              $sjohnei=@{Identity=$MBO_Name; User=$u.SID.Value; AccessRights="FullAccess"}
              if(!($automap)){$sjohnei.add("AutoMapping", $False)}
                   #Add-MailboxPermission @sjohnei | Out-Null

                   $bla = Add-MailboxPermission -Identity $MBO_Name -User $u.SID.Value -AccessRights FullAccess
              }
          }
          #Es hed nume Konti ufem Poschtfach, d'Gruppe isch lär
            elseif(!($Soette_Raecht_ha) -and ($Hei_Zurzyt_Raecht)){
              foreach($u in $Hei_Zurzyt_Raecht){
                  Remove-MailboxPermission -Identity $MBO_Name -User $u.user.SecurityIdentifier.value -AccessRights $u.AccessRights -Confirm:$false | Out-Null
              }
          }
        }
    #}
}

