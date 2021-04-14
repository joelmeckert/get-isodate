<#
(c) 2007-2021 Joel M. Eckert joel@joelmeckert.com
This code is licensed under MIT license (see LICENSE.txt for details)

.SYNOPSIS
	Gets the ISO 8601 datetime, make it easy and readable on the console
.DESCRIPTION
	ISO 8601 datetime output, optionally output to a string that is viable for Windows / NTFS / FAT filesystems
.PARAMETER Filename
	Outputs the datetime object without the colon separator, for compatibility with Windows / NTFS / FAT filesystems
.PARAMETER Console
	Writes ISO 8601 datetime to console in a readable colour format, initially inspired by a bash shell script
.INPUTS
	None
.OUTPUTS
	ISO 8601 datetime, either as stdout, filename-compatible (without colons), or to console
.NOTES
	Version:        1.3.3
	Author:         Joel Eckert
	Creation Date:  2021-04-14
	Purpose/Change: Consistent datetime tagging for logs and filenames 
.EXAMPLE
	Get-IsoDate
	  Returns ISO 8601 datetime
	Get-IsoDate -c
	  Returns ISO 8601 datetime to console with Write-Host in a readable colour format
	Get-IsoDate -f
	  Returns pseudo-ISO 8601 datetime for a Windows filename
#>

Function Get-IsoDate {
	Param (
		[Alias('f')]
		[Parameter(Mandatory=$false)]
		[switch]$Filename
		,
		[Alias('c')]
		[Parameter(Mandatory=$false)]
		[switch]$Console
	)
	# Gets the current timezone and UTC offset
	$GetTimeZone = Get-TimeZone
	$TimeZoneFormatted = '{0:d2}' -f ($GetTimeZone | Select-Object -ExpandProperty BaseUtcOffset | Select-Object -ExpandProperty Hours) + ":" + '{0:d2}' -f ($GetTimeZone | Select-Object -ExpandProperty BaseUtcOffset | Select-Object -ExpandProperty Minutes)
	$DateTime = (Get-Date -Format yyyy-MM-ddTHH:mm:ss.fff) + $TimeZoneFormatted
	
	# Outputs the date in an ISO 8601-compliant fashion, with trailing zeros for the time zone (if not Newfoundland)
	If ($Filename.IsPresent) {
		$DateTime = $DateTime -replace ":", "-"
		Return $DateTime
	}
	ElseIf ($Console.IsPresent) {
		[regex]$rxDateTime = '^(?<Year>\d\d\d\d)-(?<Month>\d\d)-(?<Day>\d\d)T(?<Hour>\d\d):(?<Minute>\d\d):(?<Second>\d\d)\.(?<Millisecond>\d\d\d)(?<Offset1>(-|\+)\d\d):(?<Offset2>\d\d)$'
		$Matches = $rxDateTime.Matches($DateTime)
		Write-Host $Matches[0].Groups['Year'].Value -ForegroundColor Green -NoNewLine
		Write-Host "-" -ForegroundColor Blue -NoNewLine
		Write-Host $Matches[0].Groups['Month'].Value -ForegroundColor Green -NoNewLine
		Write-Host "-" -ForegroundColor Blue -NoNewLine
		Write-Host $Matches[0].Groups['Day'].Value -ForegroundColor Green -NoNewLine
		Write-Host "T" -ForegroundColor Blue -NoNewLine
		Write-Host $Matches[0].Groups['Hour'].Value -ForegroundColor Yellow -NoNewLine
		Write-Host ":" -ForegroundColor Blue -NoNewLine
		Write-Host $Matches[0].Groups['Minute'].Value -ForegroundColor Yellow -NoNewLine
		Write-Host ":" -ForegroundColor Blue -NoNewLine
		Write-Host $Matches[0].Groups['Second'].Value -ForegroundColor White -NoNewLine
		Write-Host "." -ForegroundColor Blue -NoNewLine
		Write-Host $Matches[0].Groups['Millisecond'].Value -ForegroundColor DarkGray -NoNewLine
		Write-Host $Matches[0].Groups['Offset1'].Value -ForegroundColor DarkGray -NoNewLine
		Write-Host ":" -ForegroundColor Blue -NoNewLine
		Write-Host ($Matches[0].Groups['Offset2'].Value + " ") -ForegroundColor DarkGray -NoNewLine
	}
	Else {
		Return $DateTime
	}
}
