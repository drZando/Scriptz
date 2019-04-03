$aui_XC2010_und_hoecher_MB = Get-CASMailbox | Where-Object {$_.ExchangeVersion.ExchangeBuild.Major -ge 14}

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


foreach($MB_Feature in $XC_MB_Features_Eigeschafte.keys){
    $diff_Gruppe_MB_Feature = ""
    $Parameter = ""
    $aui_ADGruppe_Users = Get-ADGroupMember $XC_MB_Features_Eigeschafte.$MB_Feature.ADGruppe
    $aui_XC2010_und_hoecher_MB_mit_Feature_Enabled = $aui_XC2010_und_hoecher_MB | Where-Object $XC_MB_Features_Eigeschafte.$MB_Feature.ShellProperty -eq $true

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