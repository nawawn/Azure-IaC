#Work in Progress - Pester
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$SBT = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Write-Host $SBT
#. $ScriptPath\$SBT
Describe 'Deploy-AzManagedDiskVM'{
    $Functions = @(
        'Test-AzPSSession',
        'Test-PSDataFile',
        'Test-ResourceGroup',
        'Test-ResourceGroup',
        'Test-VirtualNetwork',
        'Test-VirtualNIC',
        'Test-VirtualMachine',
        'Base64',
        'New-VMCredential',
        'New-PSVirtualMachine'
    )
    Context "Functions Name Test"{
        It 'Should include these functions'{
            Foreach ($fn in $Functions){
                Get-Content -Path "$ScriptPath\$SBT" | Should Contain $fn
            }            
        }
    }
}
Describe 'Test-AzPSSession'{
    Mock Test-AzPSSession -MockWith {$true}
    It 'should return true'{
        Set-ItResult -Inconclusive -Because "TBC"
    }
}
Describe 'Test-PSDataFile'{
    It 'Should return true' {
        Set-ItResult -Inconclusive -Because "TBC"
    }
}

Describe 'Test-ResourceGroup'{
    It 'Should return true'{
        Set-ItResult -Inconclusive -Because "TBC"
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

