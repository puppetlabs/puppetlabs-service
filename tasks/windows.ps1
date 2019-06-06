[CmdletBinding()]
param(
  # NOTE: init.json cannot yet be shared, so must have windows.json / windows.ps1
  [Parameter(Mandatory = $true)]
  [String]
  $Name,

  [Parameter(Mandatory = $true)]
  [String]
  $Action,

  [Parameter(Mandatory = $false)]
  [Switch]
  $Force
)

function ErrorMessage($Action, $Name, $Message)
{
  Write-Host @"
{
  "status"  : "failure",
  "_error"  : {
    "msg" : "Unable to perform '$Action' on '$Name': $Message",
    "kind": "powershell_error",
    "details" : {}
  }
}
"@  
}

# Do this outside the initial script parameters in order to control the error message
function ValidateParams
{
  param(
    [ValidateSet('start', 'stop', 'restart', 'status')]
    [String]
    $Action
  )
}

$ErrorActionPreference = 'Stop'

function Invoke-ServiceAction($Service, $Action, $Force)
{
  $inSyncStatus = 'in_sync'
  $status = $null

  switch ($Action)
  {
    'start'
    {
      if ($Service.Status -eq 'Running') { $status = $InSyncStatus }
      else { Start-Service -inputObject $Service }
    }
    'stop'
    {
      if ($Service.Status -eq 'Stopped') { $status = $InSyncStatus }
      else { Stop-Service -inputObject $Service -Force:$Force }
    }
    'restart'
    {
      Restart-Service -inputObject $Service  -Force:$Force
      $status = 'Restarted'
    }
    # no-op since status always returned
    'status' { }
  }

  # user action
  if ($status -eq $null)
  {
    # For older systems this needs to be refreshed. Is there a cleaner way?
    $refresh = Get-Service -Name $service.ServiceName
    $status = $refresh.Status
    # https://msdn.microsoft.com/en-us/library/system.serviceprocess.servicecontrollerstatus(v=vs.110).aspx
    # ContinuePending, Paused, PausePending, Running, StartPending, Stopped, StopPending
    if ($status -eq 'Running') { $status = 'Started' }
  }

  return $status
}

try
{
  ValidateParams -Action $action
  $service = Get-Service -Name $Name
  $status = Invoke-ServiceAction -Service $service -Action $action  -Force:$Force

  # TODO: could use ConvertTo-Json, but that requires PS3
  # if embedding in literal, should make sure Name / Status doesn't need escaping
  if ($action -eq 'status') {
    Write-Host @"
{
  "status"      : "$status",
  "enabled"   : "$($service.StartType)"
}
"@
  } else {
    Write-Host @"
{
  "status"      : "$status"
}
"@
  }
}
# parameter validation with controlled output
catch [System.Management.Automation.ParameterBindingException]
{
  ErrorMessage -Action $Action -Name $Name -Message "'$Action' action not supported for windows.ps1"
}
catch
{
  ErrorMessage -Action $Action -Name $Name -Message "$($_.Exception.Message)"
}
