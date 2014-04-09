
$RunSimulation = $true
$Verbose = $true
$FileTypesToRemove = @('*.dll', '*.pdb', '*.xml')
$FolderNamesToInclude = @('bin', 'obj')
$FolderNamesToIgnore = @('packages', '_tools$', '_build', 'MsBuild.Tasks')
#$BasePath = (Get-Location -PSProvider FileSystem).ProviderPath
#$BasePath = "D:\"

. .\DeleteObjBin.ps1

Recursive-Directory-Cleanup $RunSimulation $Verbose $FileTypesToRemove $FolderNamesToInclude $FolderNamesToIgnore $BasePath

