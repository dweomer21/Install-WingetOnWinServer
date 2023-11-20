$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-Location $Env:TEMP

# Xaml
Write-Host 'Downloading and installing Microsoft.UI.Xaml package'
Invoke-WebRequest -Uri 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3' -OutFile 'Microsoft.UI.Xaml.v2.7.3.zip' -UseBasicParsing
Expand-Archive -LiteralPath 'Microsoft.UI.Xaml.v2.7.3.zip' -DestinationPath 'Microsoft.UI.Xaml.v2.7.3' -Force
Add-AppxPackage -Path '.\Microsoft.UI.Xaml.v2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx' -Verbose

# VCLibs
Write-Host 'Downloading and installing C++ Runtime framework packages for Desktop Bridge'
Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile 'Microsoft.VCLibs.x64.14.00.Desktop.appx' -UseBasicParsing
Add-AppxPackage -Path '.\Microsoft.VCLibs.x64.14.00.Desktop.appx' -Verbose

# WinGet
Write-Host 'Downloading and Installing WinGet'
$WingetReleases = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases' -UseBasicParsing)
$WingetLatestRelease = $WingetReleases.Where{-not $_.draft -and -not $_.prerelease}[0]
$WingetMsixBundle = $WingetLatestRelease.assets.Where{$_.name -like '*.msixbundle'}
Invoke-WebRequest -Uri ($WingetMsixBundle.browser_download_url) -OutFile ($WingetMsixBundle.name) -UseBasicParsing
$WingetLicense = $WingetLatestRelease.assets.Where{$_.name -like '*license*'}
Invoke-WebRequest -Uri ($WingetLicense.browser_download_url) -OutFile ($WingetLicense.name) -UseBasicParsing
Add-AppxProvisionedPackage -Online -PackagePath ".\$($WingetMsixBundle.name)" -LicensePath .\$($WingetLicense.name) -Verbose

# Cleanup
Write-Host 'Cleaning up'
Remove-Item -Force -LiteralPath @(
    'Microsoft.UI.Xaml.v2.7.3.zip',
    'Microsoft.VCLibs.x64.14.00.Desktop.appx',
    ($WingetMsixBundle.name),
    ($WingetLicense.name)
) -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse -LiteralPath 'Microsoft.UI.Xaml.v2.7.3' -ErrorAction SilentlyContinue
