Function Get-HostsFile {
	$hostsFile = "$home\temp\hosts.csv"

	if (-Not (Test-Path $hostsFile)) {
		throw "The file '$hostsFile' does not exist."
	}

	try {
		return Import-Csv $hostsFile
	}
	catch {
		Write-Error "Error while reading the CSV file: $_"
		return $null
	}
}