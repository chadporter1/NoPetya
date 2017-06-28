function Set-NotPeytaVaccination {
    <#
    .DESCRIPTION
        Applies the NotPeyta vaccination detailed in 
        'Vaccination discovered by twitter.com/0xAmit/status/879778335286452224.'

    .EXAMPLE
        PS C:\> Set-NotPeytaVaccination -ComputerName Server1 -Verbose
        Applies the vaccination to Server1
    .EXAMPLE
        PS C:\> 'Server1', 'Server2' | Set-NotPeytaVaccination
        Applies the vaccination to Server1 and Server2, will have no output in console
    .EXAMPLE
        PS C:\> Get-Content -Path C:\servers.txt | Set-NotPeytaVaccination -Verbose
        Assuming C:\servers.txt is a plaintext list of server names, applies the vaccination to all servers in the list
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        $ComputerName
    )
    begin {
        Write-Verbose -Message 'Administrative permissions required. Detecting permissions...'
        Write-Verbose -Message ('NOTE: This assumes the current account has admin permissions ' +
                                'on all computers this is being run against')

        $User = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not($User.IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))) {
            Write-Error -Message 'You must run this script as Administrator.' -ErrorAction Stop
        }
        
        $FileContent = ('This is a NotPetya/Petya/Petna/SortaPetya Vaccination file. ' + 
                        'Do not remove as it protects you from being encrypted by Petya.')
        $GenericFilePaths = 'perfc', 'perfc.dll', 'perfc.dat' | ForEach-Object { "\\{0}\C$\Windows\$_" }
    }

    process {
        if (Test-Connection -ComputerName $ComputerName -Quiet) {
            foreach ($File in $GenericFilePaths) {
                $DestinationFile = $File -f $ComputerName
                if (-not(Test-Path -Path $DestinationFile) -or
                    -not(Get-Item -Path $DestinationFile | Get-ItemProperty).IsReadOnly) {
                    Write-Verbose -Message ('{0} does not exist or is not ReadOnly, creating' -f $DestinationFile)
                    Get-Item -Path $DestinationFile -ErrorAction SilentlyContinue | Remove-Item -Force
                    New-Item -Path $DestinationFile -ItemType 'File' -Value $FileContent |
                        Set-ItemProperty -Name IsReadOnly -Value $true
                    
                    # Test the file
                    if (-not(Get-Item -Path $DestinationFile | Get-ItemProperty).IsReadOnly) {
                        Write-Error -Message ('{0} does not exist or is not readonly')
                    }
                }
                else {
                    Write-Verbose -Message ('{0} already exists.' -f $DestinationFile)
                }
            }
            Write-Verbose -Message ('{0} vaccinated for current version of NotPetya/Petya/Petna/SortaPetya.' -f $ComputerName)
        }
        else {
            Write-Error -Message ('{0} is not reachable.' -f $ComputerName)
        }
    }

    end {
    }
}