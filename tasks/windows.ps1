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
  $inSyncStatus = 'in_sync'
  $status = $null

  switch ($Action)
  {
    'start'
    {
      if ($Service.Status -eq 'Running') { $status = $InSyncStatus }
      else { $Service | Start-Service }
    }
    'stop'
    {
      if ($Service.Status -eq 'Stopped') { $status = $InSyncStatus }
      else { $Service | Stop-Service }
    }
    'restart'
    {
      $Service | Restart-Service
      $status = 'restarted'
    }
    # no-op since status always returned
    'status' { }
  }

  # user action
  if ($status -eq $null)
  {
    # https://msdn.microsoft.com/en-us/library/system.serviceprocess.servicecontrollerstatus(v=vs.110).aspx
    # ContinuePending, Paused, PausePending, Running, StartPending, Stopped, StopPending
    $status = $Service.Status
    if ($status -eq 'Running') { $status = 'started' }
  }

  return $status
}

try
{
  $service = Get-Service -Name $Name
  $status = Invoke-ServiceAction -Service $service -Action $action

# TODO: could use ConvertTo-Json, but that requires PS3
# if embedding in literal, should make sure Name / Status doesn't need escaping
Write-Host @"
{
  "name"        : "$($service.Name)",
  "action"      : "$Action",
  "displayName" : "$($service.DisplayName)",
  "status"      : "$status",
  "startType"   : "$($service.StartType)"
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
      "msg" : "Unable to perform '$Action' on '$Name': $($_.Exception.Message)",
      "kind": "powershell_error",
      "details" : {}
    }
  }
"@
}
