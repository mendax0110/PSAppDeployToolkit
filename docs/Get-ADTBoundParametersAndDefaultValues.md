---
external help file: PSAppDeployToolkit-help.xml
Module Name: PSAppDeployToolkit
online version: https://psappdeploytoolkit.com
schema: 2.0.0
---

# Get-ADTBoundParametersAndDefaultValues

## SYNOPSIS
Returns a hashtable with the output of $PSBoundParameters and default-valued parameters for the given InvocationInfo.

## SYNTAX

```
Get-ADTBoundParametersAndDefaultValues [-Invocation] <InvocationInfo> [[-ParameterSetName] <String>]
 [[-HelpMessage] <String>] [[-Exclude] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This function processes the provided InvocationInfo and combines the results of $PSBoundParameters and default-valued parameters via the InvocationInfo's ScriptBlock AST (Abstract Syntax Tree).

## EXAMPLES

### EXAMPLE 1
```
Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
```

Returns a $PSBoundParameters-compatible dictionary with the bound parameters and any default values.

## PARAMETERS

### -Invocation
The script or function's InvocationInfo ($MyInvocation) to process.

```yaml
Type: InvocationInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParameterSetName
The ParameterSetName to use as a filter against the Invocation's parameters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HelpMessage
The HelpMessage field to use as a filter against the Invocation's parameters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
One or more parameter names to exclude from the results.

```yaml
Type: String[]
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

### System.Collections.Generic.Dictionary[System.String, System.Object]
### Get-ADTBoundParametersAndDefaultValues returns a dictionary of the same base type as $PSBoundParameters for API consistency.
## NOTES
An active ADT session is NOT required to use this function.

Tags: psadt
Website: https://psappdeploytoolkit.com
Copyright: (c) 2024 PSAppDeployToolkit Team, licensed under LGPLv3
License: https://opensource.org/license/lgpl-3-0

## RELATED LINKS

[https://psappdeploytoolkit.com](https://psappdeploytoolkit.com)
