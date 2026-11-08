param([string]$RepositoryRoot = 'C:\Users\Laure\Documents\ChatGPT\IPT')

$ErrorActionPreference = 'Stop'
$php = 'C:\xampp\php\php.exe'
$flutter = 'E:\Flutter\flutter_windows_3.47.8-stable\flutter\bin\flutter.bat'
$logDir = Join-Path $RepositoryRoot 'submissions\week-15\logs'
$testDir = Join-Path $RepositoryRoot 'submissions\week-15\tests'

function Invoke-Checked {
    param([scriptblock]$Command, [string]$Output)
    & $Command 2>&1 | Tee-Object -LiteralPath $Output
    if ($LASTEXITCODE -ne 0) { throw "Verification command failed with exit code $LASTEXITCODE. See $Output" }
}

$started = [DateTimeOffset]::Now
Set-Location (Join-Path $RepositoryRoot 'backend')
Invoke-Checked { & $php artisan test --log-junit (Join-Path $testDir 'phpunit-results.xml') } (Join-Path $logDir 'backend-tests.txt')
Invoke-Checked { & $php vendor\bin\pint --test } (Join-Path $logDir 'pint.txt')
Set-Location (Join-Path $RepositoryRoot 'frontend')
Invoke-Checked { & $flutter test --reporter expanded } (Join-Path $logDir 'flutter-tests.txt')
Invoke-Checked { & $flutter analyze } (Join-Path $logDir 'flutter-analysis.txt')
Invoke-Checked { & $flutter build web --release --dart-define=API_URL=https://localhost:8443/api } (Join-Path $logDir 'flutter-build.txt')

Set-Location (Join-Path $RepositoryRoot 'backend')
$audit = & composer audit --format=json 2>&1
$audit | Set-Content -LiteralPath (Join-Path $logDir 'composer-audit.json') -Encoding utf8
if ($LASTEXITCODE -ne 0) { throw 'Composer audit reported an error or advisory.' }

$collection = Get-Content -Raw -LiteralPath (Join-Path $testDir 'Thesis-Consultation-Week15.postman_collection.json') | ConvertFrom-Json
$environment = [pscustomobject]@{
    executed_at = $started.ToString('o')
    completed_at = [DateTimeOffset]::Now.ToString('o')
    timezone = [TimeZoneInfo]::Local.Id
    source_state = 'uncommitted Week 15 working tree based on 133b0c8'
    php = (& $php -r 'echo PHP_VERSION;')
    laravel = (& $php artisan --version)
    flutter = ((& $flutter --version | Select-Object -First 1) -join '')
    database = (& 'C:\xampp\mysql\bin\mysqld.exe' --version)
    postman_collection_requests = @($collection.item).Count
    api_collection_result = 'submissions/week-15/tests/api-results.json'
}
$environment | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $logDir 'environment.json') -Encoding utf8
Set-Location $RepositoryRoot
'PASS: backend, frontend, analysis, formatting, build, audit, collection parse, and environment capture completed.'
