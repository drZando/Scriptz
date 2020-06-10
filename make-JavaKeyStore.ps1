[CmdletBinding()]
Param(
    [Parameter(HelpMessage = "Wo ligt das dräks Java Shit Keytool gfotz?")]
    [string]
    $keytool_Spicherort,

    [Parameter()]
    [string]
    $keytool_exe,

    [Parameter()]
    [string]
    $CSR_Spicherort,

    [Parameter()]
    [string]
    $JKS_Spicherort,

    [Parameter()]
    [string]
    $CER_Spicherort,

    [Parameter()]
    [string]
    $CER_Name,

    [Parameter()]
    [string]
    $KeyAlias,

    [Parameter()]
    [string]
    $SAN_Attr,

    [Parameter()]
    [string]
    $CN,

    [Parameter()]
    [int]
    $Schluessulaengi,

    [Parameter()]
    [string]
    $Schluessu_Algorythmus
)

if(!($KeyAlias)){
    if(!($KeyAlias = Read-Host "Wie isch dr Alias? [blablabla]")){
        $KeyAlias = "blablabla"
    }
}
if(!($SAN_Attr)){
    if(!($SAN_Attr = Read-Host "Was für SAN Attribut woschne drzue due? [SAN=dns:chischte.internet.net,dns:superchischte,ip:10.10.10.10]")){
        $SAN_Attr = "SAN=dns:chischte.internet.net,dns:superchischte,ip:10.10.10.10"
    }
}
if(!($CN)){
    if(!($CN = Read-Host "Was für CN wosch? [chischte.internet.net]")){
        $CN = "chischte.internet.net"
    }
}
if(!($keytool_Spicherort)){
    if(!($keytool_Spicherort = Read-Host "Wo ligt das Shit Keytool? [C:\Program Files (x86)\Java\jre1.8.0_251\bin]")){
        $keytool_Spicherort = "C:\Program Files (x86)\Java\jre1.8.0_251\bin"
    }
}
if(!($keytool_exe)){
    if(!($keytool_exe = Read-Host "Wie heisst d'EXE? [keytool.exe]")){
        $keytool_exe = "keytool.exe"
    }
}
if(!($JKS_Spicherort)){
    if(!($JKS_Spicherort = Read-Host "Wo söu s'JKS abgleid wärde? [c:\z\temp]")){
        $JKS_Spicherort = "c:\z\temp"
    }
}
if(!($CSR_Spicherort)){
    if(!($CSR_Spicherort = Read-Host "Wo söu dr CSR abgleid wärde? [c:\z\temp]")){
        $CSR_Spicherort = "c:\z\temp"
    }
}
if(!($CER_Spicherort)){
    if(!($CER_Spicherort = Read-Host "Wo ligt s'Zertifikat? [c:\z\temp]")){
        $CER_Spicherort = "c:\z\temp"
    }
}
if(!($CER_Name)){
    if(!($CER_Name = Read-Host "Wie heisst s'Zertifikat? [certnew.p7b]")){
        $CER_Name = "certnew.p7b"
    }
}
if(!($Schluessulaengi)){
    if(!($Schluessulaengi = Read-Host "Wie läng söu dr Schlüssu si? [4096]")){
        $Schluessulaengi = "4096"
    }
}
if(!($Schluessu_Algorythmus)){
    if(!($Schluessu_Algorythmus = Read-Host "Wele Schlüssu Algorythmus söus de si? [RSA]")){
        $Schluessu_Algorythmus = "RSA"
    }
}


$Argumaent_JKS = "-genkeypair -keyalg $Schluessu_Algorythmus -keysize $Schluessulaengi -alias $KeyAlias -ext $SAN_Attr -keystore $JKS_Spicherort\$KeyAlias.jks -storetype JKS -dname CN=$CN"
$Argumaent_CSR = "-certreq -file $CSR_Spicherort\$KeyAlias.csr -keystore $JKS_Spicherort\$KeyAlias.jks -alias $KeyAlias -ext $SAN_Attr"
$Argumaent_ImpCer = "-import -trustcacerts -alias $KeyAlias -file $CER_Spicherort\$CER_Name -keystore $JKS_Spicherort\$KeyAlias.jks"

"$keytool_Spicherort\$keytool_exe $Argumaent_JKS"
"$keytool_Spicherort\$keytool_exe $Argumaent_CSR"
"$keytool_Spicherort\$keytool_exe $Argumaent_ImpCer"

Start-Process $keytool_Spicherort\$keytool_exe $Argumaent_JKS -Wait
Start-Process $keytool_Spicherort\$keytool_exe $Argumaent_CSR -Wait
Start-Process $keytool_Spicherort\$keytool_exe $Argumaent_ImpCer -Wait
