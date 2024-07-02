﻿function Install-ADTSCCMSoftwareUpdates
{
    <#

    .SYNOPSIS
    Scans for outstanding SCCM updates to be installed and installs the pending updates.

    .DESCRIPTION
    Scans for outstanding SCCM updates to be installed and installs the pending updates.

    Only compatible with SCCM 2012 Client or higher. This function can take several minutes to run.

    .PARAMETER SoftwareUpdatesScanWaitInSeconds
    The amount of time to wait in seconds for the software updates scan to complete. Default is: 180 seconds.

    .PARAMETER WaitForPendingUpdatesTimeout
    The amount of time to wait for missing and pending updates to install before exiting the function. Default is: 45 minutes.

    .INPUTS
    None. You cannot pipe objects to this function.

    .OUTPUTS
    None. This function does not return any objects.

    .EXAMPLE
    Install-ADTSCCMSoftwareUpdates

    .LINK
    https://psappdeploytoolkit.com

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Int32]$SoftwareUpdatesScanWaitInSeconds = 180,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.TimeSpan]$WaitForPendingUpdatesTimeout = (New-TimeSpan -Minutes 45)
    )

    begin {
        # Make this function continue on error.
        $OriginalErrorAction = if ($PSBoundParameters.ContainsKey('ErrorAction'))
        {
            $PSBoundParameters.ErrorAction
        }
        else
        {
            [System.Management.Automation.ActionPreference]::Continue
        }
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        Write-ADTDebugHeader
    }

    process {
        try
        {
            # If SCCM 2007 Client or lower, exit function.
            if (($SCCMClientVersion = Get-ADTSCCMClientVersion).Major -le 4)
            {
                $naerParams = @{
                    Exception = [System.Data.VersionNotFoundException]::new('SCCM 2007 or lower, which is incompatible with this function, was detected on this system.')
                    Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                    ErrorId = 'CcmExecVersionLowerThanMinimum'
                    TargetObject = $SCCMClientVersion
                    RecommendedAction = "Please review the installed CcmExec client and try again."
                }
                throw (New-ADTErrorRecord @naerParams)
            }

            # Trigger SCCM client scan for Software Updates.
            $StartTime = [System.DateTime]::Now
            Write-ADTLogEntry -Message 'Triggering SCCM client scan for Software Updates...'
            Invoke-ADTSCCMTask -ScheduleId 'SoftwareUpdatesScan'
            Write-ADTLogEntry -Message "The SCCM client scan for Software Updates has been triggered. The script is suspended for [$SoftwareUpdatesScanWaitInSeconds] seconds to let the update scan finish."
            Start-Sleep -Seconds $SoftwareUpdatesScanWaitInSeconds

            # Find the number of missing updates.
            try
            {
                Write-ADTLogEntry -Message 'Getting the number of missing updates...'
                [Microsoft.Management.Infrastructure.CimInstance[]]$CMMissingUpdates = Get-CimInstance -Namespace ROOT\CCM\ClientSDK -Query "SELECT * FROM CCM_SoftwareUpdate WHERE ComplianceState = '0'"
            }
            catch
            {
                Write-ADTLogEntry -Message "Failed to find the number of missing software updates.`n$(Resolve-ADTError)" -Severity 2
                throw
            }

            # Install missing updates and wait for pending updates to finish installing.
            if (!$CMMissingUpdates.Count)
            {
                Write-ADTLogEntry -Message 'There are no missing updates.'
                return
            }

            # Install missing updates.
            Write-ADTLogEntry -Message "Installing missing updates. The number of missing updates is [$($CMMissingUpdates.Count)]."
            $CMInstallMissingUpdates = (Get-CimInstance -Namespace ROOT\CCM\ClientSDK -ClassName CCM_SoftwareUpdatesManager -List).InstallUpdates($CMMissingUpdates)

            # Wait for pending updates to finish installing or the timeout value to expire.
            do
            {
                Start-Sleep -Seconds 60
                [Microsoft.Management.Infrastructure.CimInstance[]]$CMInstallPendingUpdates = Get-CimInstance -Namespace ROOT\CCM\ClientSDK -Query 'SELECT * FROM CCM_SoftwareUpdate WHERE EvaluationState = 6 or EvaluationState = 7'
                Write-ADTLogEntry -Message "The number of updates pending installation is [$($CMInstallPendingUpdates.Count)]."
            }
            while (($CMInstallPendingUpdates.Count -ne 0) -and ([System.DateTime]::Now - $StartTime) -lt $WaitForPendingUpdatesTimeout)
        }
        catch
        {
            Write-ADTLogEntry -Message "Failed to trigger installation of missing software updates.`n$(Resolve-ADTError)" -Severity 3
            $ErrorActionPreference = $OriginalErrorAction
            $PSCmdlet.WriteError($_)
        }
    }

    end {
        Write-ADTDebugFooter
    }
}