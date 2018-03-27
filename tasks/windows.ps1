[CmdletBinding()]
param(
  # NOTE: init.json cannot yet be shared, so must have windows.json / windows.ps1
  [Parameter(Mandatory = $true)]
  [String]
  $Name,

  [Parameter(Mandatory = $true)]
  [ValidateSet('start', 'stop', 'restart', 'status')]
  [String]
  $Action
)

$ErrorActionPreference = 'Stop'

function Invoke-ServiceAction($Service, $Action)
{
  switch ($Action)
  {
    'start' { Start-Service $Service }
    'stop' { Stop-Service $Service }
    'restart' { Restart-Service $Service }
    # no-op since status always returned
    'status' { }
  }

  # https://msdn.microsoft.com/en-us/library/system.serviceprocess.servicecontrollerstatus(v=vs.110).aspx
  # ContinuePending, Paused, PausePending, Running, StartPending, Stopped, StopPending
  $status = $Service.Status
  if ($status -eq 'Running') { $status = 'Started' }

  return $status
}

try
{
  $initialStatus = 'unavailable'
  $service = Get-Service -Name $Name
  $initialStatus = $Service.Status
  if ($initialStatus -eq 'Running') { $initialStatus = 'Started' }
  $status = Invoke-ServiceAction -Service $service -Action $action

# TODO: could use ConvertTo-Json, but that requires PS3
# if embedding in literal, should make sure Name / Status doesn't need escaping
Write-Host @"
{
  "name"          : "$($service.Name)",
  "action"        : "$Action",
  "displayName"   : "$($service.DisplayName)",
  "initialStatus" : "$initialStatus",
  "status"        : "$status",
  "startType"     : "$($service.StartType)"
}
"@
}
catch
{
  Write-Host @"
  {
    "status"  : "failure",
    "name"    : "$Name",
    "action"  : "$Action",
    "_error"  : {
      "msg" : "Unable to perform '$Action' on '$Name' ($initialStatus): $($_.Exception.Message)",
      "kind": "powershell_error",
      "details" : {}
    }
  }
"@
}
