<#
(c) 2007-2021 Joel M. Eckert joel@joelmeckert.com
This code is licensed under MIT license (see LICENSE.txt for details)

.SYNOPSIS
	Gets the ISO 8601 datetime, it's unfortunate that it is such a complex process
.DESCRIPTION
	ISO 8601 datetime output, optionally output to a string that is viable for Windows / NTFS / FAT filesystems
.PARAMETER Filename
	Outputs the datetime object without the colon separator, for compatibility with Windows / NTFS / FAT filesystems
.INPUTS
	None
.OUTPUTS
	ISO 8601 datetime, either as stdout, filename-compatible (without colons), or out to the console
.NOTES
	Version:        1.3.1
	Author:         Joel Eckert
	Creation Date:  2021-01-04
	Purpose/Change: Consistent datetime tagging for logs and filenames 
.EXAMPLE
	Get-IsoDate
	  Returns ISO 8601 datetime
	Get-IsoDate -c
	  Returns ISO 8601 datetime to console in a readable coloured format, initially inspired by a bash shell script
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
	$TimeZone = (Get-TimeZone | Select-Object -ExpandProperty BaseUtcOffset).ToString()
	$TimeZoneFormatted = $TimeZone.Substring(0, $TimeZone.Length - 3) + "Z"
		
	# Outputs the date in an ISO 8601-compliant fashion, with trailing zeros for the time zone (if not Newfoundland)
	$DateTime = (Get-Date -Format yyyy-MM-ddTHH:MM:ss.fff) + $TimeZoneFormatted
	If ($Filename.IsPresent) {
		$DateTime = $DateTime -replace ":", "-"
	}
	ElseIf ($Console.IsPresent) {
		$Year = $DateTime.Substring(0,4)
		$Month = $DateTime.Substring(5,2)
		$Day = $DateTime.Substring(8,2)
		$Hour = $DateTime.Substring(11,2)
		$Minute = $DateTime.Substring(14,2)
		$Second = $DateTime.Substring(17,2)
		$Nanosecond = $DateTime.Substring(20,3)
		$TZ1 = $DateTime.Substring(23,3)
		$TZ2 = $DateTime.Substring(27,3)

		Write-Host $Year -ForegroundColor Green -NoNewLine
		Write-Host "-" -ForegroundColor Blue -NoNewLine
		Write-Host $Month -ForegroundColor Green -NoNewLine
		Write-Host "-" -ForegroundColor Blue -NoNewLine
		Write-Host $Day -ForegroundColor Green -NoNewLine
		Write-Host "T" -ForegroundColor Blue -NoNewLine
		Write-Host $Hour -ForegroundColor Yellow -NoNewLine
		Write-Host ":" -ForegroundColor Blue -NoNewLine
		Write-Host $Minute -ForegroundColor Yellow -NoNewLine
		Write-Host ":" -ForegroundColor Blue -NoNewLine
		Write-Host $Second -ForegroundColor White -NoNewLine
		Write-Host "." -ForegroundColor Blue -NoNewLine
		Write-Host $Nanosecond -ForegroundColor DarkGray -NoNewLine
		Write-Host $TZ1 -ForegroundColor DarkGray -NoNewLine
		Write-Host ":" -ForegroundColor Blue -NoNewLine
		Write-Host "$TZ2 " -ForegroundColor DarkGray -NoNewLine
	}
	Else {
		Return $DateTime
	}
}