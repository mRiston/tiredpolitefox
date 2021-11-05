#script generation to create objects in FortiGate to allow for region-based policies.

$Raw = Import-Csv C:\scripts\FortiNetCountryCodes.csv -Delimiter '|'

<#$TemplateCode = "edit `"$($line.CountryName.Replace(',',''))`"
set type geography
set country $($line.CountryCode)
set color 24
next
"
#>
$TemplateCode = "edit `"{0}`"
set type geography
set country {1}
set color 24
next
"
$ToRun = @()
$ToRun += "config firewall address"
foreach ($line in $Raw){
  $code = $line.CountryCode
  $name = $line.CountryName.Replace(',','')
  $ToRun +=   $TemplateCode -f $name,$code
}