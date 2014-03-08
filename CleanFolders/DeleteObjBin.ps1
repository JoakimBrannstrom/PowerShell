Function DoesNotMatch($value, $filterArray)
{
	foreach ($item in $filterArray)
	{
		if($value.IndexOf($item) -gt 0)
		{
			return $false
		}
	}

	return $true
}

Function PrintFolders($Header, $BasePath, $Folders, $Visible, $Color)
{
	if(!($Color)) { $Color = 'red' }

	if($Visible -and $Folders -ne $null)
	{
		Write-Host
		Write-Host $Folders.count $Header -foregroundcolor $color
		foreach ($folder in $Folders)
		{
			$currentPath = $folder.Replace($BasePath, "\")
			Write-Host ".$currentPath" -foregroundcolor $color
		}
	}
}

Function PrintSummary($RemovedFileSize, $color)
{
	Write-Host
	$totalRemovedFileSize += ($RemovedFileSize | Measure-Object -property sum -sum)
	$mbRemoved = "{0:N3}" -f ($totalRemovedFileSize.sum / 1MB) + " MB"
	Write-Host "$nrOfRemovedFiles files ($mbRemoved) removed" -foregroundcolor $color
}

Function Recursive-Directory-Cleanup($RunSimulation, $Verbose, $FileTypesToRemove, $FolderNamesToInclude, $FolderNamesToIgnore, $BasePath)
{
	if(!($RunSimulation)) { $RunSimulation = $true }
	if(!($Verbose)) { $Verbose = $false }
	if(!($FileTypesToRemove)) { $FileTypesToRemove = @('*.dll', '*.pdb') }
	if(!($FolderNamesToIgnore)) { $FolderNamesToIgnore = @('packages', '_tools', '_build') }
	if(!($BasePath)) { $BasePath = (Get-Location -PSProvider FileSystem).ProviderPath }

	if (-not $BasePath.EndsWith('\')) { $BasePath += '\' }

	$removalColor = 'Cyan'
	$ignoreColor = 'Yellow'

	Write-Host
	Write-Host "BasePath: $BasePath" -foregroundcolor 'magenta'

	# Recursively get all folders matching the given folder names
	$AllFolders = Get-ChildItem $BasePath -include $FolderNamesToInclude -Recurse | foreach { $_.fullname }

	# Which of these folders should we clean then?
	$FoldersToRemove = @()
	$FoldersToRemove += $AllFolders | where { DoesNotMatch $_ $FolderNamesToIgnore }
	# PrintFolders "folder(s) to clean:" $BasePath $FoldersToRemove $Verbose $removalColor

	# And which folders will we ignore?
	$FolderNamesToIgnore = @()
	$FolderNamesToIgnore += $AllFolders | where { $FoldersToRemove -notcontains $_ }
	PrintFolders "folder(s) ignored:" $BasePath $FolderNamesToIgnore $Verbose $ignoreColor

	$nrOfRemovedFiles = 0
	$RemovedFileSize = @()

	if($FoldersToRemove -ne $null)
	{
		Write-Host
		if(!$RunSimulation)
		{
			Write-Host "Removing files..." -foregroundcolor $removalColor
		}
		else
		{
			Write-Host "Simulating removal of files..." -foregroundcolor $removalColor
		}

		foreach ($item in $FoldersToRemove)
		{
			$files = Get-ChildItem $item -include $FileTypesToRemove -Recurse | foreach { $_.fullname }

			if($files -ne $null)
			{
				$currentFileSize = (Get-ChildItem $files | Measure-Object -property length -sum)
				$RemovedFileSize += $currentFileSize

				if($Verbose)
				{
					$mbToRemove = "{0:N3}" -f ($currentFileSize.sum / 1MB) + " MB"
					$currentPath = $item.Replace($BasePath, "\")
					Write-Host "'.$currentPath' $($files.count) file(s), $mbToRemove total"  -foregroundcolor $removalColor
				}

				foreach ($file in $files)
				{
					$nrOfRemovedFiles++
					if(!$RunSimulation)
					{
						#Remove-Item $file -Force
					}

					<#
					if($Verbose)
					{
						Write-Host $file.Replace($BasePath, "")  -foregroundcolor $removalColor
					}
					#>
				}
			}
		}
	}

	PrintSummary $RemovedFileSize $removalColor
	Write-Host
}

<#
# Usage:
$RunSimulation = $true
$Verbose = $true
$FileTypesToRemove = @('*.dll', '*.pdb', '*.xml')
$FolderNamesToInclude = @('bin', 'obj')
$FolderNamesToIgnore = @('_tools$', '_build')

Recursive-Directory-Cleanup $RunSimulation $Verbose $FileTypesToRemove $FolderNamesToInclude $FolderNamesToIgnore
#>
