. "$PSScriptRoot\Private\Get-HostByEnvironment.ps1"
. "$PSScriptRoot\Private\Get-HostsFile.ps1"
. "$PSScriptRoot\Private\Split-BackupXml.ps1"

<#
.SYNOPSIS
Connects to a selected SailPoint IIQ environment on Linux, downloads the latest backup, and optionally extracts and parses its XML contents.

.DESCRIPTION
This cmdlet allows the user to interactively select an environment and host from a configuration CSV located under $HOME\Temp.
It connects via SSH to the selected IdentityIQ Linux host, downloads the daily backup archive (in .tar.gz format) for the current day or a user-defined date, and extracts it locally to $HOME\Temp\TAG_yyyyMMdd_bk.
Optionally, it parses one or more specific XML files within the backup and splits their contents into individual files.

.PARAMETER Date
Specifies the date of the backup to retrieve. Must be in the format yyyyMMdd (e.g. 20250519).
If not provided, the current system date is used by default.

.PARAMETER Application
Parses the Application XML file (Application_yyyMMddT*.xml) and creates one file per application.

.PARAMETER AuditConfig
Parses the AuditConfig XML file and creates one file per audit configuration.

.PARAMETER AuthenticationQuestion
Parses the AuthenticationQuestion XML file and creates one file per authentication question.

.PARAMETER Bundle
Parses the Bundle XML file and creates one file per bundle.

.PARAMETER Capability
Parses the Capability XML file and creates one file per capability.

.PARAMETER CorrelationConfig
Parses the CorrelationConfig XML file and creates one file per correlation configuration.

.PARAMETER EmailTemplate
Parses the EmailTemplate XML file and creates one file per template.

.PARAMETER Form
Parses the Form XML file and creates one file per form.

.PARAMETER IdentityTrigger
Parses the IdentityTrigger XML file and creates one file per identity trigger.

.PARAMETER PasswordPolicy
Parses the PasswordPolicy XML file and creates one file per password policy.

.PARAMETER Plugin
Parses the Plugin XML file and creates one file per plugin definition.

.PARAMETER Policy
Parses the Policy XML file and creates one file per policy.

.PARAMETER QuickLink
Parses the QuickLink XML file and creates one file per quick link.

.PARAMETER RoleChangeEvent
Parses the RoleChangeEvent XML file and creates one file per role change event.

.PARAMETER Rule
Parses the Rule XML file and creates one file per rule.

.PARAMETER Server
Parses the Server XML file and creates one file per server entry.

.PARAMETER SPRight
Parses the SPRight XML file and creates one file per right.

.PARAMETER TaskDefinition
Parses the TaskDefinition XML file and creates one file per task definition.

.PARAMETER TaskSchedule
Parses the TaskSchedule XML file and creates one file per task schedule.

.PARAMETER UIConfig
Parses the UIConfig XML file and creates one file per UI configuration.

.PARAMETER Workflow
Parses the Workflow XML file and creates one file per workflow.

.EXAMPLE
Invoke-IIQBackup

Downloads and extracts the backup for today's date, without parsing.

.EXAMPLE
Invoke-IIQBackup -Date 20250519 -Application -Rule

Downloads and extracts the backup from May 19, 2025, and parses both the Application and Rule XML files.

.NOTES
Author: GVNADIR
Module: SailPoint.IIQ.LinuxBackup
Version: 1.0.0
CSV Path: $HOME\Temp\ (must contain the configuration CSV file)
Extraction Path: $HOME\Temp\TAG_yyyyMMdd_bk
#>
Function Invoke-IIQBackup {
	param (
		[string]$Date,
		[switch]$Application,
		[switch]$AuditConfig,
		[switch]$AuthenticationQuestion,
		[switch]$Bundle,
		[switch]$Capability, 
		# [switch]$Configuration, not working, error while parsing
		[switch]$CorrelationConfig, 
		[switch]$EmailTemplate, 
		[switch]$Form, 
		[switch]$IdentityTrigger, 
		[switch]$PasswordPolicy, 
		[switch]$Plugin, 
		[switch]$Policy, 
		[switch]$QuickLink, 
		[switch]$RoleChangeEvent, 
		[switch]$Rule, 
		[switch]$Server, 
		[switch]$SPRight, 
		[switch]$TaskDefinition, 
		[switch]$TaskSchedule, 
		[switch]$UIConfig, 
		[switch]$Workflow
	)

	$tagMap = @{
		Application            = $Application
		AuditConfig            = $AuditConfig
		AuthenticationQuestion = $AuthenticationQuestion
		Bundle                 = $Bundle
		Capability             = $Capability
		CorrelationConfig      = $CorrelationConfig
		EmailTemplate          = $EmailTemplate
		Form                   = $Form
		IdentityTrigger        = $IdentityTrigger
		PasswordPolicy         = $PasswordPolicy
		Plugin                 = $Plugin
		Policy                 = $Policy
		QuickLink              = $QuickLink
		RoleChangeEvent        = $RoleChangeEvent
		Rule                   = $Rule
		Server                 = $Server
		SPRight                = $SPRight
		TaskDefinition         = $TaskDefinition
		TaskSchedule           = $TaskSchedule
		UIConfig               = $UIConfig
		Workflow               = $Workflow
	}

	$selectedHost = Get-HostByEnvironment
	Write-Host "`nYou selected: $($selectedHost.Name) ($($selectedHost.Hostname))"

	$remoteUser = $selectedHost.User
	$remoteHost = $selectedHost.Hostname
	$remoteHostTag = $selectedHost.Tag
	$remoteFolder = $selectedHost.Backup
	
	if ($null -eq $Date -or $Date -eq "") {
		$today = Get-Date -Format "yyyyMMdd"
		$backupFile = "${today}_backup.tar.gz"
		$extractPath = "$HOME/Temp/${remoteHostTag}_${today}_bk"
	}
 else {
		$backupFile = "${Date}_backup.tar.gz"
		$extractPath = "$HOME/Temp/${remoteHostTag}_${Date}_bk"
	}

	$remoteFilePath = "$remoteFolder/$backupFile"

	Write-Host "`nArchive will be extracted to: $extractPath"
	$localDownloadPath = Join-Path $extractPath $backupFile
			
	if (-not (Test-Path -Path $extractPath)) {
		New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
	}

	scp "${remoteUser}@${remoteHost}:${remoteFilePath}" "$localDownloadPath"
			
	Write-Output "Extracting Archive..."
	tar -xzf $localDownloadPath -C $extractPath
			
	Write-Host "`nArchive extracted to: $extractPath"

	foreach ($entry in $tagMap.GetEnumerator()) {
		$tagName = $entry.Key
		$isEnabled = $entry.Value
	
		if ($isEnabled) {
			$isAuthQuestion = $tagName -eq "AuthenticationQuestion"
			$isRoleChangeEvent = $tagName -eq "RoleChangeEvent"

			$out = Join-Path $extractPath $tagName
			$xmlPath = Get-ChildItem -Path "$extractPath\${tagName}_*.xml" | Select-Object -First 1

			if ($isAuthQuestion) {
				Split-BackupXml -XmlPath $xmlPath -OutputDirectory $out $tagName -FileName "question"
			}
			elseif ($isRoleChangeEvent) {
				Split-BackupXml -XmlPath $xmlPath -OutputDirectory $out $tagName -FileName "bundleName"
			}
			else {
				Split-BackupXml -XmlPath $xmlPath -OutputDirectory $out $tagName
			}
		}
	}
}