param(
    [string]$RepositoryRoot = 'C:\Users\Laure\Documents\ChatGPT\IPT',
    [string]$Output = 'submissions\week-14\logs\secret-scan.json'
)

$ErrorActionPreference = 'Stop'
$keyringPath = Join-Path $RepositoryRoot 'backend\storage\app\private\secure-exchange-keyring.json'
$envPath = Join-Path $RepositoryRoot 'backend\.env'
$sensitiveValues = [System.Collections.Generic.List[string]]::new()
if (Test-Path -LiteralPath $keyringPath) {
    $ring = Get-Content -Raw -LiteralPath $keyringPath | ConvertFrom-Json
    foreach ($property in $ring.keys.psobject.Properties) { $sensitiveValues.Add([string]$property.Value) }
}
$passwordLine = Get-Content -LiteralPath $envPath | Where-Object { $_ -match '^DEMO_PASSWORD=' } | Select-Object -First 1
if ($passwordLine) { $sensitiveValues.Add((($passwordLine -replace '^DEMO_PASSWORD=', '').Trim('"', "'"))) }

$extensions = @('.php', '.dart', '.ps1', '.py', '.md', '.json', '.yaml', '.yml', '.xml', '.txt', '.example', '.mmd', '.svg')
$relativeFiles = & git -C $RepositoryRoot ls-files --cached --others --exclude-standard
$findings = [System.Collections.Generic.List[object]]::new()
$scanned = 0
foreach ($relative in $relativeFiles) {
    $path = Join-Path $RepositoryRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    $extension = [IO.Path]::GetExtension($path).ToLowerInvariant()
    if ($extensions -notcontains $extension -and [IO.Path]::GetFileName($path) -ne '.env.example') { continue }
    $text = Get-Content -Raw -LiteralPath $path -ErrorAction SilentlyContinue
    if ($null -eq $text) { continue }
    $scanned++
    if ($text -match '-----BEGIN (RSA |EC |)PRIVATE KEY-----') {
        $findings.Add([pscustomobject]@{ path = $relative; rule = 'private-key-block' })
    }
    if ($text -match '(?m)^SECURE_EXCHANGE_KEY=[ \t]*[^ \t\r\n]+') {
        $findings.Add([pscustomobject]@{ path = $relative; rule = 'nonempty-example-key' })
    }
    foreach ($value in $sensitiveValues) {
        if ($value.Length -ge 8 -and $text.Contains($value)) {
            $findings.Add([pscustomobject]@{ path = $relative; rule = 'exact-generated-secret-match' })
        }
    }
}
$ignored = @(
    'backend/storage/app/private/secure-exchange-keyring.json',
    'backend/storage/app/private/tls/ca.key',
    'backend/storage/app/private/tls/localhost.key'
) | ForEach-Object {
    $ignoredPath = Join-Path $RepositoryRoot $_
    & git -C $RepositoryRoot check-ignore -q $ignoredPath
    $isIgnored = $LASTEXITCODE -eq 0
    [pscustomobject]@{ path = $_; ignored = $isIgnored }
}
$result = [pscustomobject]@{
    executed_at = [DateTimeOffset]::Now.ToString('o')
    candidate_text_files_scanned = $scanned
    sensitive_values_compared = $sensitiveValues.Count
    matches = $findings
    protected_paths = $ignored
    passed = ($findings.Count -eq 0 -and @($ignored | Where-Object { -not $_.ignored }).Count -eq 0)
}
$destination = Join-Path $RepositoryRoot $Output
New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($destination)) | Out-Null
$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $destination -Encoding utf8
if (-not $result.passed) { throw "Secret scan found $($findings.Count) match(es) or an unignored protected path." }
"PASS: $scanned candidate text files scanned; no generated secret matches; protected paths ignored."
