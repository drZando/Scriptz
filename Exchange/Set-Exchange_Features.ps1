##########################################################################################################
# Set-Exchange_Features.ps1 
# 
# Author: Z
##########################################################################################################
# Powershell Script um die Exchange Features zu konfigurieren
#
# Dieses Script geht durch die entsprechenden Gruppen im Active Directory
# und konfiguriert dementsprechend die Exchange Features der Benutzer
# somit muss nur die Gruppe im Active Directory gewartet werden und sobald
# das Script läuft, wird der Exchange "synchronisiert"
##########################################################################################################
# Release Notes:
# 1.0.1 - 26.07.2019: Verbindig zum Exchange via PSSession anstatt RemoteExchange.ps1 
# 1.0.0 - 09.11.2015: Initialer Release
##########################################################################################################
$fqdnMailboxServer = "MB-SERVER.domain.tld"

#------- Nütme alänge ------------------------------------------------------------------------------------
$Session = New-PSSession -ConnectionURI "http://$fqdnMailboxServer/powershell?serializationLevel=Full" -ConfigurationName Microsoft.Exchange
Import-PSSession $Session
Import-Module ActiveDirectory

$aui_XC2010_und_hoecher_MB = Get-CASMailbox

$XC_MB_Features_Eigeschafte = @{
    OWA = @{
        ADGruppe = "GS_PR_XC-OWA-Benutzer_NZ"
        ShellProperty = "OWAEnabled"
        }
    EAS = @{
        ADGruppe = "GS_PR_XC-EAS-Benutzer_NZ"
        ShellProperty = "ActiveSyncEnabled"
        }
    IMAP = @{
        ADGruppe = "GS_PR_XC-IMAP-Benutzer_NZ"
        ShellProperty = "ImapEnabled"
        }
    POP = @{
        ADGruppe = "GS_PR_XC-POP-Benutzer_NZ"
        ShellProperty = "PopEnabled"
        }
} 


foreach($MB_Feature in $XC_MB_Features_Eigeschafte.Keys){
    $diff_Gruppe_MB_Feature = $null
    $Parameter = $null
    $aui_ADGruppe_Users = Get-ADGroupMember $XC_MB_Features_Eigeschafte.$MB_Feature.ADGruppe
    $aui_XC2010_und_hoecher_MB_mit_Feature_Enabled = $aui_XC2010_und_hoecher_MB | Where-Object {$_.$($XC_MB_Features_Eigeschafte.$MB_Feature.ShellProperty) -eq $true}

    if((!($aui_XC2010_und_hoecher_MB_mit_Feature_Enabled)) -and (!($aui_ADGruppe_Users))){
    }
    elseif($aui_ADGruppe_Users -and $aui_XC2010_und_hoecher_MB_mit_Feature_Enabled){
        $diff_Gruppe_MB_Feature = Compare-Object -ReferenceObject $aui_ADGruppe_Users.SamAccountName -DifferenceObject $aui_XC2010_und_hoecher_MB_mit_Feature_Enabled.SamAccountName

        foreach($u in $diff_Gruppe_MB_Feature){
            switch($u.SideIndicator){
                    "=>" {$Parameter = @{Identity = $u.InputObject; $XC_MB_Features_Eigeschafte.$MB_Feature.ShellProperty = $false}; Set-CASMailbox @Parameter}
                    "<=" {$Parameter = @{Identity = $u.InputObject; $XC_MB_Features_Eigeschafte.$MB_Feature.ShellProperty = $true}; Set-CASMailbox @Parameter}
            }
        }
    }
    elseif(!($aui_ADGruppe_Users)){
        foreach($u in $aui_XC2010_und_hoecher_MB_mit_Feature_Enabled){
            $Parameter = @{Identity = $u.SamAccountName; $XC_MB_Features_Eigeschafte.$MB_Feature.ShellProperty = $false}
            Set-CASMailbox @Parameter
        }
    }
    elseif(!($aui_XC2010_und_hoecher_MB_mit_Feature_Enabled)){
        foreach($u in $aui_ADGruppe_Users){
            $Parameter = @{Identity = $u.SamAccountName; $XC_MB_Features_Eigeschafte.$MB_Feature.ShellProperty = $true}
            Set-CASMailbox @Parameter
        }
    }
}