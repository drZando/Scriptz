$aui_XC2010_und_hoecher_MB = Get-CASMailbox -Identity * | Where-Object {$_.ExchangeVersion.ExchangeBuild.Major -ge "14"}

# ------------------------------------------------------------------------------------
# - IMAP und POP für aui deaktiviere
# ------------------------------------------------------------------------------------
$aui_XC2010_und_hoecher_MB | Where-Object {$_.ImapEnabled -eq $true} | ForEach-Object{Set-CASMailbox $_.Identity -ImapEnabled $false}
$aui_XC2010_und_hoecher_MB | Where-Object {$_.PopEnabled -eq $true} | ForEach-Object{Set-CASMailbox $_.Identity -PopEnabled $false}

# ------------------------------------------------------------------------------------
# - OWA Berächtigunge setze anhand vor Gruppezueghörigkeit im AD
# ------------------------------------------------------------------------------------
$MedS_OWA_Users_Gruppe = "GS_PR_XC-OWA-Benutzer_NZ"
$aui_OWA_Users = Get-ADGroupMember $MedS_OWA_Users_Gruppe

$aui_XC2010_und_hoecher_MB_und_OWA_Enabled = $aui_XC2010_und_hoecher_MB | Where-Object {$_.OWAEnabled -eq $true}

$diff_Gruppe_CASMB_OWA = Compare-Object -ReferenceObject $aui_OWA_Users.SamAccountName -DifferenceObject $aui_XC2010_und_hoecher_MB_und_OWA_Enabled.SamAccountName
# Konto isch im XC berächtigt ir Gruppe aber nid -> Im XC Rächt wägnä
$diff_Gruppe_CASMB_OWA | Where-Object {$_.SideIndicator -eq "=>"} | ForEach-Object{Set-CASMailbox $_.InputObject -OWAEnabled $false}
# Konto isch ir Gruppe berächtigt im XC aber nid -> Im XC Rächt gä
$diff_Gruppe_CASMB_OWA | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object{Set-CASMailbox $_.InputObject -OWAEnabled $true}

# ------------------------------------------------------------------------------------
# - EAS Berächtigunge setze anhand vor Gruppezueghörigkeit im AD
# ------------------------------------------------------------------------------------
$MedS_EAS_Users_Gruppe = "GS_PR_XC-EAS-Benutzer_NZ"
$aui_EAS_Users = Get-ADGroupMember $MedS_EAS_Users_Gruppe

$aui_XC2010_und_hoecher_MB_und_EAS_Enabled = $aui_XC2010_und_hoecher_MB | Where-Object {$_.ActiveSyncEnabled -eq $true}

$diff_Gruppe_CASMB_EAS = Compare-Object -ReferenceObject $aui_EAS_Users.SamAccountName -DifferenceObject $aui_XC2010_und_hoecher_MB_und_EAS_Enabled.SamAccountName
# Konto isch im XC berächtigt ir Gruppe aber nid -> Im XC Rächt wägnä
$diff_Gruppe_CASMB_EAS | Where-Object {$_.SideIndicator -eq "=>"} | ForEach-Object{Set-CASMailbox $_.InputObject -ActiveSyncEnabled $false}
# Konto isch ir Gruppe berächtigt im XC aber nid -> Im XC Rächt gä
$diff_Gruppe_CASMB_EAS | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object{Set-CASMailbox $_.InputObject -ActiveSyncEnabled $true}

# ------------------------------------------------------------------------------------