﻿#---------------------------------------------------------------------------
#
#
#
#---------------------------------------------------------------------------

function Get-ADTRegistryKey
{
    <#

    .SYNOPSIS
    Retrieves value names and value data for a specified registry key or optionally, a specific value.

    .DESCRIPTION
    Retrieves value names and value data for a specified registry key or optionally, a specific value.

    If the registry key does not exist or contain any values, the function will return $null by default. To test for existence of a registry key path, use built-in Test-Path cmdlet.

    .PARAMETER Key
    Path of the registry key.

    .PARAMETER Value
    Value to retrieve (optional).

    .PARAMETER Wow6432Node
    Specify this switch to read the 32-bit registry (Wow6432Node) on 64-bit systems.

    .PARAMETER SID
    The security identifier (SID) for a user. Specifying this parameter will convert a HKEY_CURRENT_USER registry key to the HKEY_USERS\$SID format.

    Specify this parameter from the Invoke-ADTAllUsersRegistryChange function to read/edit HKCU registry settings for all users on the system.

    .PARAMETER ReturnEmptyKeyIfExists
    Return the registry key if it exists but it has no property/value pairs underneath it. Default is: $false.

    .PARAMETER DoNotExpandEnvironmentNames
    Return unexpanded REG_EXPAND_SZ values. Default is: $false.

    .INPUTS
    None. You cannot pipe objects to this function.

    .OUTPUTS
    System.String. Returns the value of the registry key or value.

    .EXAMPLE
    Get-ADTRegistryKey -Key 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1AD147D0-BE0E-3D6C-AC11-64F6DC4163F1}'

    .EXAMPLE
    Get-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe'

    .EXAMPLE
    Get-ADTRegistryKey -Key 'HKLM:Software\Wow6432Node\Microsoft\Microsoft SQL Server Compact Edition\v3.5' -Value 'Version'

    .EXAMPLE
    # Return %ProgramFiles%\Java instead of C:\Program Files\Java
    Get-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Value 'Path' -DoNotExpandEnvironmentNames

    .EXAMPLE
    Get-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Example' -Value '(Default)'

    .NOTES
    This function can be called without an active ADT session.

    .LINK
    https://psappdeploytoolkit.com

    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Key,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Value,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$Wow6432Node,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$SID,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$ReturnEmptyKeyIfExists,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$DoNotExpandEnvironmentNames
    )

    begin
    {
        # Make this function continue on error.
        Initialize-ADTFunction -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue
    }

    process
    {
        try
        {
            try
            {
                # If the SID variable is specified, then convert all HKEY_CURRENT_USER key's to HKEY_USERS\$SID.
                [String]$Key = if ($PSBoundParameters.ContainsKey('SID'))
                {
                    Convert-ADTRegistryPath -Key $Key -Wow6432Node:$Wow6432Node -SID $SID
                }
                else
                {
                    Convert-ADTRegistryPath -Key $Key -Wow6432Node:$Wow6432Node
                }

                # Check if the registry key exists before continuing.
                if (!(& $Script:CommandTable.'Test-Path' -LiteralPath $Key))
                {
                    Write-ADTLogEntry -Message "Registry key [$Key] does not exist. Return `$null." -Severity 2
                    return
                }

                if ($PSBoundParameters.ContainsKey('Value'))
                {
                    Write-ADTLogEntry -Message "Getting registry key [$Key] value [$Value]."
                }
                else
                {
                    Write-ADTLogEntry -Message "Getting registry key [$Key] and all property values."
                }

                # Get all property values for registry key.
                $regKeyValue = & $Script:CommandTable.'Get-ItemProperty' -LiteralPath $Key
                $regKeyValuePropertyCount = $regKeyValue | & $Script:CommandTable.'Measure-Object' | & $Script:CommandTable.'Select-Object' -ExpandProperty Count

                # Select requested property.
                if ($PSBoundParameters.ContainsKey('Value'))
                {
                    # Get the Value (do not make a strongly typed variable because it depends entirely on what kind of value is being read)
                    if ((& $Script:CommandTable.'Get-Item' -LiteralPath $Key | & $Script:CommandTable.'Select-Object' -ExpandProperty Property -ErrorAction Ignore) -notcontains $Value)
                    {
                        Write-ADTLogEntry -Message "Registry key value [$Key] [$Value] does not exist. Return `$null."
                        return
                    }
                    if ($DoNotExpandEnvironmentNames)
                    {
                        # Only useful on 'ExpandString' values.
                        if ($Value -like '(Default)')
                        {
                            return (& $Script:CommandTable.'Get-Item' -LiteralPath $Key).GetValue($null, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                        }
                        else
                        {
                            return (& $Script:CommandTable.'Get-Item' -LiteralPath $Key).GetValue($Value, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                        }
                    }
                    elseif ($Value -like '(Default)')
                    {
                        return (& $Script:CommandTable.'Get-Item' -LiteralPath $Key).GetValue($null)
                    }
                    else
                    {
                        return $regKeyValue | & $Script:CommandTable.'Select-Object' -ExpandProperty $Value
                    }
                }
                elseif ($regKeyValuePropertyCount -eq 0)
                {
                    # Select all properties or return empty key object.
                    if ($ReturnEmptyKeyIfExists)
                    {
                        Write-ADTLogEntry -Message "No property values found for registry key. Return empty registry key object [$Key]."
                        return (& $Script:CommandTable.'Get-Item' -LiteralPath $Key -Force)
                    }
                    else
                    {
                        Write-ADTLogEntry -Message "No property values found for registry key. Return `$null."
                    }
                }
            }
            catch
            {
                & $Script:CommandTable.'Write-Error' -ErrorRecord $_
            }
        }
        catch
        {
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage $(if ($Value)
            {
                "Failed to read registry key [$Key] value [$Value]."
            }
            else
            {
                "Failed to read registry key [$Key]."
            })
        }
    }

    end
    {
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}