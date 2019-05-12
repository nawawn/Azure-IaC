#Work in Progress - Pester
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$SBT = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Test.",".")
. $ScriptPath\$SBT

Describe 'Test-AzPSSession'{
    Mock Test-AzPSSession -MockWith 
    It 'should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}
Describe 'Test-PSDataFile'{
    It 'Should return true' {
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'Test-ResourceGroup'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'Test-VirtualNetwork'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'Test-VirtualNIC'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'Test-VirtualMachine'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'Base64'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'New-VMCredential'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

Describe 'New-PSVirtualMachine'{
    It 'Should return true'{
        Set-TestInconclusive -Message "TBC"
    }
}

