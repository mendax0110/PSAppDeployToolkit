﻿#---------------------------------------------------------------------------
#
#
#
#---------------------------------------------------------------------------

function Show-ADTInstallationProgressClassic
{
    <#

    .SYNOPSIS
    Displays a progress dialog in a separate thread with an updateable custom message.

    .DESCRIPTION
    Create a WPF window in a separate thread to display a marquee style progress ellipse with a custom message that can be updated. The status message supports line breaks.

    The first time this function is called in a script, it will display a balloon tip notification to indicate that the installation has started (provided balloon tips are enabled in the configuration).

    .PARAMETER WindowTitle
    The title of the window to be displayed. The default is the derived value from $InstallTitle.

    .PARAMETER StatusMessage
    The status message to be displayed. The default status message is taken from the configuration file.

    .PARAMETER WindowLocation
    The location of the progress window. Default: center of the screen.

    .PARAMETER NotTopMost
    Specifies whether the progress window shouldn't be topmost. Default: $false.

    .PARAMETER Quiet
    Specifies whether to not log the success of updating the progress message. Default: $false.

    .PARAMETER NoRelocation
    Specifies whether to not reposition the window upon updating the message. Default: $false.

    .INPUTS
    None. You cannot pipe objects to this function.

    .OUTPUTS
    None. This function does not generate any output.

    .EXAMPLE
    # Use the default status message from the configuration file.
    Show-ADTInstallationProgressClassic

    .EXAMPLE
    Show-ADTInstallationProgressClassic -StatusMessage 'Installation in Progress...'

    .EXAMPLE
    Show-ADTInstallationProgressClassic -StatusMessage "Installation in Progress...`nThe installation may take 20 minutes to complete."

    .EXAMPLE
    Show-ADTInstallationProgressClassic -StatusMessage 'Installation in Progress...' -WindowLocation 'BottomRight' -TopMost $false

    .LINK
    https://psappdeploytoolkit.com

    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'DisableWindowCloseButton', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'UpdateWindowLocation', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'UnboundArguments', Justification = "This parameter is just to trap any superfluous input at the end of the function's call.")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$WindowTitle,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$StatusMessage,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Default', 'TopLeft', 'Top', 'TopRight', 'TopCenter', 'BottomLeft', 'Bottom', 'BottomRight')]
        [System.String]$WindowLocation = 'Default',

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$NotTopMost,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$Quiet,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$NoRelocation,

        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]$UnboundArguments
    )

    # Internal worker function.
    function Update-WindowLocation
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'This is an internal worker function that requires no end user confirmation.')]
        [CmdletBinding(SupportsShouldProcess = $false)]
        param
        (
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [System.Windows.Window]$Window,

            [Parameter(Mandatory = $false)]
            [ValidateSet('Default', 'TopLeft', 'Top', 'TopRight', 'TopCenter', 'BottomLeft', 'Bottom', 'BottomRight')]
            [System.String]$WindowLocation = 'Default'
        )

        # Calculate the position on the screen where the progress dialog should be placed.
        [System.Double]$screenCenterWidth = [System.Windows.SystemParameters]::WorkArea.Width - $Window.ActualWidth
        [System.Double]$screenCenterHeight = [System.Windows.SystemParameters]::WorkArea.Height - $Window.ActualHeight

        # Set the start position of the Window based on the screen size.
        switch ($WindowLocation)
        {
            'TopLeft' {
                $Window.Left = 0.
                $Window.Top = 0.
                break
            }
            'Top' {
                $Window.Left = $screenCenterWidth * 0.5
                $Window.Top = 0.
                break
            }
            'TopRight' {
                $Window.Left = $screenCenterWidth
                $Window.Top = 0.
                break
            }
            'TopCenter' {
                $Window.Left = $screenCenterWidth * 0.5
                $Window.Top = $screenCenterHeight * (1. / 6.)
                break
            }
            'BottomLeft' {
                $Window.Left = 0.
                $Window.Top = $screenCenterHeight
                break
            }
            'Bottom' {
                $Window.Left = $screenCenterWidth * 0.5
                $Window.Top = $screenCenterHeight
                break
            }
            'BottomRight' {
                # The -100 offset is needed to not overlap system tray toast notifications.
                $Window.Left = $screenCenterWidth
                $Window.Top = $screenCenterHeight - 100
                break
            }
            default {
                # Center the progress window by calculating the center of the workable screen based on the width of the screen minus half the width of the progress bar
                $Window.Left = $screenCenterWidth * 0.5
                $Window.Top = $screenCenterHeight * 0.5
                break
            }
        }
    }

    # Check if the progress thread is running before invoking methods on it.
    if (!$Script:ProgressWindow.Running)
    {
        # Load up the XML file.
        $adtConfig = Get-ADTConfig
        $xaml = $Script:ProgressWindow.XamlCode.PSObject.Copy()
        $xaml.Window.Title = $xaml.Window.ToolTip = $WindowTitle
        $xaml.Window.TopMost = (!$NotTopMost).ToString()
        $xaml.Window.Grid.TextBlock.Text = $StatusMessage

        # Set up the PowerShell instance and add the initial scriptblock.
        $Script:ProgressWindow.PowerShell = [System.Management.Automation.PowerShell]::Create().AddScript({
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.Xml.XmlDocument]$Xaml,

                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.IO.FileInfo]$Icon,

                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.IO.FileInfo]$Banner,

                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.Management.Automation.ScriptBlock]$UpdateWindowLocation,

                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.Management.Automation.ScriptBlock]$DisableWindowCloseButton
            )

            # Set required variables to ensure script functionality.
            $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
            $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            Set-StrictMode -Version 3

            # Create XAML window and bring it up.
            try
            {
                $SyncHash.Add('Window', [System.Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($Xaml)))
                $SyncHash.Add('Message', $SyncHash.Window.FindName('ProgressText'))
                $SyncHash.Window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.IO.MemoryStream]::new([System.IO.File]::ReadAllBytes($Icon)), [System.Windows.Media.Imaging.BitmapCreateOptions]::IgnoreImageCache, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
                $SyncHash.Window.FindName('ProgressBanner').Source = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.IO.MemoryStream]::new([System.IO.File]::ReadAllBytes($Banner)), [System.Windows.Media.Imaging.BitmapCreateOptions]::IgnoreImageCache, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
                $SyncHash.Window.add_MouseLeftButtonDown({$this.DragMove()})
                $SyncHash.Window.add_Loaded({
                    # Relocate the window and disable the X button.
                    & $UpdateWindowLocation.GetNewClosure() -Window $this
                    & $DisableWindowCloseButton.GetNewClosure() -WindowHandle ([System.Windows.Interop.WindowInteropHelper]::new($this).Handle)
                })
                $null = $SyncHash.Window.ShowDialog()
            }
            catch
            {
                $SyncHash.Error = $_
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }).AddArgument($Xaml).AddArgument($adtConfig.Assets.Logo).AddArgument($adtConfig.Assets.Banner).AddArgument(${Function:Update-WindowLocation}).AddArgument(${Function:Disable-ADTWindowCloseButton})

        # Commence invocation.
        Write-ADTLogEntry -Message "Creating the progress dialog in a separate thread with message: [$StatusMessage]."
        $Script:ProgressWindow.PowerShell.Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $Script:ProgressWindow.PowerShell.Runspace.ApartmentState = [System.Threading.ApartmentState]::STA
        $Script:ProgressWindow.PowerShell.Runspace.ThreadOptions = [System.Management.Automation.Runspaces.PSThreadOptions]::ReuseThread
        $Script:ProgressWindow.PowerShell.Runspace.Open()
        $Script:ProgressWindow.PowerShell.Runspace.SessionStateProxy.SetVariable('SyncHash', $Script:ProgressWindow.SyncHash)
        $Script:ProgressWindow.Invocation = $Script:ProgressWindow.PowerShell.BeginInvoke()

        # Allow the thread to be spun up safely before invoking actions against it.
        while (!($Script:ProgressWindow.SyncHash.ContainsKey('Window') -and $Script:ProgressWindow.SyncHash.Window.IsInitialized -and $Script:ProgressWindow.SyncHash.Window.Dispatcher.Thread.ThreadState.Equals([System.Threading.ThreadState]::Running)))
        {
            if ($Script:ProgressWindow.SyncHash.ContainsKey('Error'))
            {
                throw $Script:ProgressWindow.SyncHash.Error
            }
            elseif ($Script:ProgressWindow.Invocation.IsCompleted)
            {
                $naerParams = @{
                    Exception = [System.InvalidOperationException]::new("The separate thread completed without presenting the progress dialog.")
                    Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                    ErrorId = 'InstallationProgressDialogFailure'
                    TargetObject = $(if ($SyncHash.ContainsKey('Window')) {$SyncHash.Window})
                    RecommendedAction = "Please review the result in this error's TargetObject property and try again."
                }
                throw (New-ADTErrorRecord @naerParams)
            }
        }

        # If we're here, the window came up.
        $Script:ProgressWindow.Running = $true
    }
    else
    {
        # Invoke update events against an established window.
        $Script:ProgressWindow.SyncHash.Window.Dispatcher.Invoke(
            {
                $Script:ProgressWindow.SyncHash.Window.Title = $WindowTitle
                $Script:ProgressWindow.SyncHash.Message.Text = $StatusMessage
                if (!$args[0])
                {
                    Update-WindowLocation -Window $Script:ProgressWindow.SyncHash.Window -WindowLocation $args[1]
                }
            },
            [System.Windows.Threading.DispatcherPriority]::Send,
            ($NoRelocation, $WindowLocation)
        )
        Write-ADTLogEntry -Message "Updated the progress message: [$StatusMessage]." -DebugMessage:$Quiet
    }
}