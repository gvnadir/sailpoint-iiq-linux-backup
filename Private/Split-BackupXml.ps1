function Split-BackupXml {
	param (
		[string]$XmlPath,
		[string]$OutputDirectory,
		[string]$TagName,
		[string]$FileName
	)

	[xml]$xmlContent = Get-Content -Path $XmlPath

	if (-not (Test-Path -Path $OutputDirectory)) { 
		New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
	}

	$nodes = $xmlContent.SelectNodes("//sailpoint/$TagName")

	foreach ($node in $nodes) {
		if (-not $FileName) {
			$nodeName = $node.name
		}
		else {
			$nodeName = $node.$FileName
		}

		if ([string]::IsNullOrWhiteSpace($nodeName)) {
			Write-Warning "$TagName without '$FileName' attribute. Skipped."
			continue
		}

		$safeFileName = ($nodeName -replace '[\\\/:*?"<>|]', '_')

		$xmlHeader = "<?xml version='1.0' encoding='UTF-8'?>`n<!DOCTYPE sailpoint PUBLIC `"sailpoint.dtd`" `"sailpoint.dtd`">`n<sailpoint>`n"
		$xmlFooter = "`n</sailpoint>"
		$nodeXml = $xmlHeader + $node.OuterXml + $xmlFooter

		$filePath = Join-Path $OutputDirectory ($safeFileName + ".xml")
		Set-Content -Path $filePath -Value $nodeXml -Encoding UTF8
		Write-Output "Exported XML: $safeFileName.xml"
	}
}