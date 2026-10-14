#requires -Version 5.1
<#
.SYNOPSIS
  Runs the demo data generator using Node.js in the existing Docker app container.
.DESCRIPTION
  Uses HTTP API only, no direct SQL. Reads the local infra/.env without printing credentials.
#>
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$infra = Join-Path $root 'test-manager-library-3145555-infra'
$compose = Join-Path $infra 'compose.yaml'
$envFile = Join-Path $infra '.env'
$seedFile = Join-Path $PSScriptRoot 'seed.mjs'
foreach ($path in @($compose, $envFile, $seedFile)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required file not found: $path"
    }
}
$values = @{}
foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
    if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
        $values[$Matches[1]] = $Matches[2].Trim()
    }
}
if (-not $values.ContainsKey('ADMIN_USERNAME') -or -not $values.ContainsKey('ADMIN_PASSWORD') -or -not $values['ADMIN_USERNAME'] -or -not $values['ADMIN_PASSWORD']) {
    throw 'Admin credentials are missing from infra/.env.'
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker CLI is unavailable. Start Docker Desktop.'
}
Write-Host '[Manager Library] Verifying Docker services...' -ForegroundColor Cyan
& docker compose --env-file $envFile -f $compose ps --status running
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose is unavailable.' }
Write-Host '[Manager Library] Copying the API-only seeder into the existing Node container...' -ForegroundColor Cyan
& docker compose --env-file $envFile -f $compose cp $seedFile 'app:/tmp/manager-library-seed.mjs'
if ($LASTEXITCODE -ne 0) { throw 'Could not copy the seeder.' }
$adminUsername = [string]$values['ADMIN_USERNAME']
$adminPassword = [string]$values['ADMIN_PASSWORD']
Write-Host '[Manager Library] Creating demo books, members and loans...' -ForegroundColor Cyan
& docker compose --env-file $envFile -f $compose exec -T -e 'API_URL=http://api:8000/api/v1' -e "ADMIN_USERNAME=$adminUsername" -e "ADMIN_PASSWORD=$adminPassword" app node /tmp/manager-library-seed.mjs
if ($LASTEXITCODE -ne 0) { throw 'The seeder failed. See the output above.' }
Write-Host '[OK] Demo generation finished. The three overdue items still require an instructor-approved fixture.' -ForegroundColor Green
