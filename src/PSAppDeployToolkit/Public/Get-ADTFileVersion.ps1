﻿#-----------------------------------------------------------------------------
#
# MARK: Get-ADTFileVersion
#
#-----------------------------------------------------------------------------

function Get-ADTFileVersion
{
    <#
    .SYNOPSIS
        Gets the version of the specified file.

    .DESCRIPTION
        The Get-ADTFileVersion function retrieves the version information of the specified file. By default, it returns the FileVersion, but it can also return the ProductVersion if the -ProductVersion switch is specified.

    .PARAMETER File
        The path of the file.

    .PARAMETER ProductVersion
        Switch that makes the command return ProductVersion instead of FileVersion.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        System.String

        Returns the version of the specified file.

    .EXAMPLE
        Get-ADTFileVersion -File "$env:ProgramFilesX86\Adobe\Reader 11.0\Reader\AcroRd32.exe"

        This example retrieves the FileVersion of the specified Adobe Reader executable.

    .EXAMPLE
        Get-ADTFileVersion -File "$env:ProgramFilesX86\Adobe\Reader 11.0\Reader\AcroRd32.exe" -ProductVersion

        This example retrieves the ProductVersion of the specified Adobe Reader executable.

    .NOTES
        An active ADT session is NOT required to use this function.

        Tags: psadt
        Website: https://psappdeploytoolkit.com
        Copyright: (c) 2024 PSAppDeployToolkit Team, licensed under LGPLv3
        License: https://opensource.org/license/lgpl-3-0

    .LINK
        https://psappdeploytoolkit.com
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (!$_.VersionInfo -or (!$_.VersionInfo.FileVersion -and !$_.VersionInfo.ProductVersion))
                {
                    $PSCmdlet.ThrowTerminatingError((New-ADTValidateScriptErrorRecord -ParameterName File -ProvidedValue $_ -ExceptionMessage 'The file does not exist or does not have any version info.'))
                }
                return !!$_.VersionInfo
            })]
        [System.IO.FileInfo]$File,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$ProductVersion
    )

    begin
    {
        Initialize-ADTFunction -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }

    process
    {
        if ($ProductVersion)
        {
            Write-ADTLogEntry -Message "Product version is [$($File.VersionInfo.ProductVersion)]."
            return $File.VersionInfo.ProductVersion.Trim()
        }
        Write-ADTLogEntry -Message "File version is [$($File.VersionInfo.FileVersion)]."
        return $File.VersionInfo.FileVersion.Trim()
    }

    end
    {
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}