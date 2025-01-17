Push-Location $PSScriptRoot;

$targetPath = '..\';

$isAppveyor = $True -eq $env:APPVEYOR;

If (!$isAppveyor)
{
    Write-Host "Running a local build";

    $targetPath = Join-Path $targetPath 'artifacts';
}

dotnet restore ..\GitExtensions.PluginManager.sln
dotnet publish ..\src\PackageManager.UI\PackageManager.UI.csproj -c Release -p:PublishProfile=FolderProfile
dotnet publish ..\src\GitExtensions.PluginManager\GitExtensions.PluginManager.csproj --configuration Release -verbosity:minimal
if (!($LastExitCode -eq 0))
{
    Pop-Location;
    Write-Error -Message "MSBuild failed with $LastExitCode" -ErrorAction Stop
}

if (!(Test-Path $targetPath))
{
      New-Item -ItemType Directory -Force -Path $targetPath
}

Copy-Item ..\src\GitExtensions.PluginManager\bin\Release\GitExtensions.PluginManager.*.zip $targetPath
Copy-Item ..\src\GitExtensions.PluginManager\bin\Release\GitExtensions.PluginManager.*.nupkg $targetPath

Pop-Location;