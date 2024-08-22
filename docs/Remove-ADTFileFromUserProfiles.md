---
external help file: PSAppDeployToolkit-help.xml
Module Name: PSAppDeployToolkit
online version: https://psappdeploytoolkit.com
schema: 2.0.0
---

# Remove-ADTFileFromUserProfiles

## SYNOPSIS
Removes one or more items from each user profile on the system.

## SYNTAX

### Path
```
Remove-ADTFileFromUserProfiles [-Path] <String[]> [-Recurse] [-ExcludeNTAccount <String[]>]
 [-ExcludeDefaultUser] [-IncludeSystemProfiles] [-IncludeServiceProfiles] [<CommonParameters>]
```

### LiteralPath
```
Remove-ADTFileFromUserProfiles [-LiteralPath] <String[]> [-Recurse] [-ExcludeNTAccount <String[]>]
 [-ExcludeDefaultUser] [-IncludeSystemProfiles] [-IncludeServiceProfiles] [<CommonParameters>]
```

## DESCRIPTION
This function removes one or more items from each user profile on the system.
It can handle both wildcard paths and literal paths.
If the specified path does not exist, it logs a warning instead of throwing an error.
The function can also delete items recursively if the Recurse parameter is specified.
Additionally, it allows excluding specific NT accounts, system profiles, service profiles, and the default user profile.

## EXAMPLES

### EXAMPLE 1
```
Remove-ADTFileFromUserProfiles -Path "AppData\Roaming\MyApp\config.txt"
```

Removes the specified file from each user profile on the system.

### EXAMPLE 2
```
Remove-ADTFileFromUserProfiles -Path "AppData\Local\MyApp" -Recurse
```

Removes the specified folder and all its contents recursively from each user profile on the system.

## PARAMETERS

### -Path
Specifies the path to append to the root of the user profile to be resolved.
The value of Path will accept wildcards.
Will accept an array of values.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath
Specifies the path to append to the root of the user profile to be resolved.
The value of LiteralPath is used exactly as it is typed; no characters are interpreted as wildcards.
Will accept an array of values.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
Deletes the files in the specified location(s) and in all child items of the location(s).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeNTAccount
Specify NT account names in Domain\Username format to exclude from the list of user profiles.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDefaultUser
Exclude the Default User.
Default is: $false.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSystemProfiles
Include system profiles: SYSTEM, LOCAL SERVICE, NETWORK SERVICE.
Default is: $false.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeServiceProfiles
Include service profiles where NTAccount begins with NT SERVICE.
Default is: $false.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### None
### This function does not generate any output.
## NOTES
An active ADT session is NOT required to use this function.

Tags: psadt
Website: https://psappdeploytoolkit.com
Copyright: (c) 2024 PSAppDeployToolkit Team, licensed under LGPLv3
License: https://opensource.org/license/lgpl-3-0

## RELATED LINKS

[https://psappdeploytoolkit.com](https://psappdeploytoolkit.com)
