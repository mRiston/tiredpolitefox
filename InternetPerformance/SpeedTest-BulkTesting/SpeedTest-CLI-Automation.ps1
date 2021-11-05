# SpeedTest Script to constantly compare the speeds acquired by various connection methods. (LAN/WLAN)
 
# Loosly adapted from: https://www.cyberdrain.com/monitoring-with-powershell-monitoring-internet-speeds/
 
# Set Working Dir
#Push-Location (Split-Path -path $MyInvocation.MyCommand.Definition -Parent)
$workingDir = 'C:\scripts\WirelessPerformance'
$speedtestInterval = 15 #How often this test will cycle after a sucessful test on all relevant adapters.

New-Item $workingDir -ItemType Directory -Force -ErrorAction SilentlyContinue
Push-Location $workingDir

 
# Check for Speedtest CLI install, if not exist, download and install.
# Replace the Download URL to where you've uploaded the ZIP file yourself. We will only download this file once.
# Latest version can be found at: https://www.speedtest.net/nl/apps/cli
Write-Host "Checking for Speedtest CLI..." -ForegroundColor Black -BackgroundColor Green

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
$DownloadLocation = "$($workingDir)\SpeedtestCLI"

try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) {
        Write-Host "Does not Exist, retreiving..." -ForegroundColor Black -BackgroundColor Yellow
        New-Item $DownloadLocation -ItemType Directory -force
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip"
        Expand-Archive "$($DownloadLocation)\speedtest.zip" $DownloadLocation -Force
    }
}
catch { 
    write-host "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"  -ForegroundColor Black -BackgroundColor Red
    exit 1
}

#File downloaded. Check it extracted correctly or it exists.
if (Test-Path "$DownloadLocation\speedtest.exe") {
  #Speedtest.exe exists. Continue.
  
  #Get our physical adapters
  $adapters = Get-NetAdapter Ethernet,Wi-Fi
  
  #Get critical information and IPs associated with adapters.
  $NetAdapters = $adapters | select Name,MediaConnectionState,@{L='IP';E={(Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4).IPAddress} }
  
  #Loop to test
  while (1) {
  
    foreach ($adapter in $NetAdapters) {
  
      # Get Speedtest Data Append to CSV
      Write-Host "Running Speedtest..." -ForegroundColor Black -BackgroundColor Green
      $SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" -i $($adapter.IP) --format=json
      $SpeedtestResults.Trim() | Out-File "$workingDir\Speedtests.raw.json" -Append
  
    }
  
    Start-Sleep -Seconds $speedtestInterval
  }

}

