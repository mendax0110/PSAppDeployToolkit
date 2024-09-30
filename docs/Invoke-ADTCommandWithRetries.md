---
external help file: PSAppDeployToolkit-help.xml
Module Name: PSAppDeployToolkit
online version: https://psappdeploytoolkit.com
schema: 2.0.0
---

# Invoke-ADTCommandWithRetries

## SYNOPSIS
Drop-in replacement for any cmdlet/function where a retry is desirable due to transient issues.

## SYNTAX

```
Invoke-ADTCommandWithRetries [-Command] <Object> [[-Retries] <UInt32>] [[-SleepSeconds] <UInt32>]
 [[-Parameters] <System.Collections.Generic.List`1[System.Object]>] [<CommonParameters>]
```

## DESCRIPTION
This function invokes the specified cmdlet/function, accepting all of its parameters but retries an operation for the configured value before throwing.

## EXAMPLES

### EXAMPLE 1
```
Invoke-ADTCommandWithRetries -Command Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile "$($adtSession.DirSupportFiles)\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
```

Downloads the latest WinGet installer to the SupportFiles directory.

## PARAMETERS

### -Command
The name of the command to invoke.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Retries
How many retries to perform before throwing.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -SleepSeconds
How many seconds to sleep between retries.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parameters
A 'ValueFromRemainingArguments' parameter to collect the parameters as would be passed to the provided Command.

While values can be directly provided to this parameter, it's not designed to be explicitly called.

```yaml
Type: System.Collections.Generic.List`1[System.Object]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
### You cannot pipe objects to this function.
## OUTPUTS

### System.Object
### Invoke-ADTCommandWithRetries returns the output of the invoked command.
## NOTES
An active ADT session is NOT required to use this function.

Tags: psadt
Website: https://psappdeploytoolkit.com
Copyright: (c) 2024 PSAppDeployToolkit Team, licensed under LGPLv3
License: https://opensource.org/license/lgpl-3-0

## RELATED LINKS

[https://psappdeploytoolkit.com](https://psappdeploytoolkit.com)
