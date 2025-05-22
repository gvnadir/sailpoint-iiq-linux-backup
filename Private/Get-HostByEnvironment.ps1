Function Get-HostByEnvironment {
	do {
		Write-Host "Choose which environment to connect to:`n"
		Write-Host "1) Development"
		Write-Host "2) Staging"
		Write-Host "3) Production"
	
		$choice = Read-Host "`nEnter choice (1-3)"
	
		$hosts = Get-HostsFile
	
		switch ($choice) {
			'1' {
				$hosts = $hosts | Where-Object { $_.Environment -like "dev*" }
				$validChoice = $true
			}
			'2' {
				$hosts = $hosts | Where-Object { $_.Environment -like "staging" }
				$validChoice = $true
			}
			'3' {
				$hosts = $hosts | Where-Object { $_.Environment -like "prod*" }
				$validChoice = $true
			}
			default {
				Write-Warning "Invalid choice, try again."
				$validChoice = $false
			}
		}
	} while ( -not $validChoice )

	$i = 1
	$menuMap = @{}
	foreach ($host in $hosts) {
		Write-Host "$i) $($host.Name) [$($host.Hostname)]"
		$menuMap[$i] = $host
		$i++
	}

	do {
		$selection = Read-Host "`nEnter the number of the host"
	} while (-not $menuMap.ContainsKey([int]$selection))

	$selectedHost = $menuMap[[int]$selection]
	return $selectedHost
}