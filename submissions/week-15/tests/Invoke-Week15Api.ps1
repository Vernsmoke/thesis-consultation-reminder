param(
    [string]$BaseUrl = 'https://localhost:8443/api',
    [string]$RepositoryRoot = 'C:\Users\Laure\Documents\ChatGPT\IPT'
)

$ErrorActionPreference = 'Stop'
$started = [DateTimeOffset]::Now
$envPath = Join-Path $RepositoryRoot 'backend\.env'
$passwordLine = Get-Content -LiteralPath $envPath | Where-Object { $_ -match '^DEMO_PASSWORD=' } | Select-Object -First 1
if (-not $passwordLine) { throw 'DEMO_PASSWORD is not configured in the private backend environment.' }
$demoPassword = ($passwordLine -replace '^DEMO_PASSWORD=', '').Trim('"', "'")

$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.CheckCertificateRevocationList = $false
$client = [System.Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromSeconds(15)

function Invoke-ControlledApi {
    param([string]$Method, [string]$Path, [object]$Body, [string]$Token, [string]$IdempotencyKey)
    $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($Method), "$BaseUrl$Path")
    $request.Headers.Accept.ParseAdd('application/json')
    if ($Token) { $request.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $Token) }
    if ($IdempotencyKey) { $request.Headers.Add('Idempotency-Key', $IdempotencyKey) }
    if ($null -ne $Body) {
        $json = $Body | ConvertTo-Json -Depth 12 -Compress
        $request.Content = [System.Net.Http.StringContent]::new($json, [Text.Encoding]::UTF8, 'application/json')
    }
    $response = $client.Send($request)
    $text = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    $parsed = if ($text) { $text | ConvertFrom-Json } else { $null }
    $headers = @{}
    foreach ($name in @('X-Correlation-ID', 'Content-Security-Policy', 'Permissions-Policy', 'Strict-Transport-Security')) {
        if ($response.Headers.Contains($name)) { $headers[$name] = $response.Headers.GetValues($name) | Select-Object -First 1 }
    }
    [pscustomobject]@{ Status = [int]$response.StatusCode; Body = $parsed; Headers = $headers }
}

function Add-Result {
    param([string]$Id, [string]$Category, [string]$Scenario, [object]$Expected, [object]$Actual, [bool]$Passed, [string]$Message, [string]$Correlation)
    $script:results.Add([pscustomobject]@{
        id = $Id; category = $Category; scenario = $Scenario; expected = $Expected; actual = $Actual
        passed = $Passed; message = $Message; correlation_id = $Correlation; time = [DateTimeOffset]::Now.ToString('o')
    })
}

function Sign-In([string]$Role) {
    $response = Invoke-ControlledApi POST '/login' @{ email = "$Role@example.test"; password = $demoPassword } $null $null
    if ($response.Status -ne 200) { throw "Controlled $Role sign-in failed with HTTP $($response.Status)." }
    $response.Body.token
}

try {
    $results = [System.Collections.Generic.List[object]]::new()
    $studentToken = Sign-In 'student'
    $panelToken = Sign-In 'panel'
    $key = 'w15_' + [DateTimeOffset]::Now.ToString('yyyyMMddHHmmssfff')
    $scheduled = [DateTimeOffset]::UtcNow.AddDays(2).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $payload = @{ agenda = 'Week 15 controlled integration test'; scheduled_at = $scheduled; adviser_id = 2; panel_id = 3 }

    $response = Invoke-ControlledApi POST '/consultations' $payload $studentToken $key
    Add-Result 'API-01' 'normal' 'valid consultation request' 201 $response.Status ($response.Status -eq 201) $response.Body.message $response.Headers['X-Correlation-ID']
    $createdId = $response.Body.id

    $response = Invoke-ControlledApi POST '/consultations' $payload $studentToken $key
    Add-Result 'API-02' 'duplicate' 'same key and payload is replayed once' 200 $response.Status ($response.Status -eq 200 -and $response.Body.replayed -eq $true -and $response.Body.id -eq $createdId) 'Replayed original resource without duplication.' $response.Headers['X-Correlation-ID']

    $changed = $payload.Clone(); $changed.agenda = 'Week 15 changed duplicate payload'
    $response = Invoke-ControlledApi POST '/consultations' $changed $studentToken $key
    Add-Result 'API-03' 'duplicate' 'same key with changed payload conflicts' 409 $response.Status ($response.Status -eq 409) $response.Body.message $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi POST '/consultations' @{ agenda = 'bad' } $studentToken ('w15_invalid_' + [Guid]::NewGuid().ToString('N'))
    Add-Result 'API-04' 'invalid' 'missing fields and short agenda' 422 $response.Status ($response.Status -eq 422) $response.Body.message $response.Headers['X-Correlation-ID']

    $boundaryPayload = $payload.Clone(); $boundaryPayload.agenda = ('x' * 1000)
    $response = Invoke-ControlledApi POST '/consultations' $boundaryPayload $studentToken ('w15_boundary_' + [Guid]::NewGuid().ToString('N'))
    Add-Result 'API-05' 'boundary' 'maximum 1000-character agenda' 201 $response.Status ($response.Status -eq 201) 'Maximum accepted boundary saved.' $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi GET '/consultations' $null $null $null
    Add-Result 'API-06' 'unauthorized' 'missing bearer token' 401 $response.Status ($response.Status -eq 401) $response.Body.message $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi GET '/automation' $null $studentToken $null
    Add-Result 'API-07' 'forbidden' 'student requests coordinator metrics' 403 $response.Status ($response.Status -eq 403) $response.Body.message $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi PATCH '/actions/999999/complete' @{} $studentToken $null
    Add-Result 'API-08' 'not-found' 'unknown action item' 404 $response.Status ($response.Status -eq 404) $response.Body.message $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi GET '/consultations?per_page=1' $null $studentToken $null
    $paginationPass = $response.Status -eq 200 -and @($response.Body.data).Count -eq 1 -and $response.Body.pagination.per_page -eq 1
    Add-Result 'API-09' 'contract' 'bounded page and metadata' 200 $response.Status $paginationPass 'One record plus pagination metadata returned.' $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi GET '/consultations?per_page=0' $null $studentToken $null
    Add-Result 'API-10' 'boundary' 'invalid zero page size' 422 $response.Status ($response.Status -eq 422) $response.Body.message $response.Headers['X-Correlation-ID']

    $invalidEnvelope = @{ version = 1; key_id = 'local-v1'; message_id = [Guid]::NewGuid().ToString(); issued_at = [DateTimeOffset]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'); expires_at = [DateTimeOffset]::UtcNow.AddMinutes(5).ToString('yyyy-MM-ddTHH:mm:ssZ'); sender = 'thesis-consultation-api'; recipient_user_id = 3; nonce = 'invalid-controlled-value'; ciphertext = 'invalid-controlled-value'; tag = 'invalid-controlled-value' }
    $response = Invoke-ControlledApi POST '/secure-exchange/receive' $invalidEnvelope $panelToken $null
    Add-Result 'API-11' 'authorization' 'panel rejected before cryptographic detail' 403 $response.Status ($response.Status -eq 403 -and $response.Body.message -eq 'Assigned adviser required.') $response.Body.message $response.Headers['X-Correlation-ID']

    $response = Invoke-ControlledApi GET '/consultations?per_page=1' $null $studentToken $null
    $headersPass = $response.Headers.ContainsKey('Content-Security-Policy') -and $response.Headers.ContainsKey('Permissions-Policy') -and $response.Headers.ContainsKey('Strict-Transport-Security')
    Add-Result 'API-12' 'security' 'HTTPS API hardening headers' 'CSP, Permissions-Policy, HSTS' ($response.Headers.Keys -join ', ') $headersPass 'Required response headers present.' $response.Headers['X-Correlation-ID']

    $unavailable = $false
    $failureType = $null
    $probeHandler = [System.Net.Http.HttpClientHandler]::new()
    $probeClient = [System.Net.Http.HttpClient]::new($probeHandler)
    $probeClient.Timeout = [TimeSpan]::FromSeconds(2)
    try { $null = $probeClient.GetAsync('https://localhost:65530/api/consultations').GetAwaiter().GetResult() }
    catch { $unavailable = $true; $failureType = $_.Exception.GetType().Name }
    finally { $probeClient.Dispose(); $probeHandler.Dispose() }
    Add-Result 'API-13' 'dependency-failure' 'unavailable endpoint is bounded by client timeout/error' 'connection failure within 2 seconds' $failureType $unavailable 'No retry loop or sensitive response.' $null

    $response = Invoke-ControlledApi GET '/consultations?per_page=1' $null $studentToken $null
    Add-Result 'API-14' 'recovery' 'approved endpoint works after unavailable probe' 200 $response.Status ($response.Status -eq 200) 'Healthy service remained usable after controlled failure.' $response.Headers['X-Correlation-ID']

    $passed = @($results | Where-Object passed).Count
    $output = [pscustomobject]@{
        executed_at = $started.ToString('o'); completed_at = [DateTimeOffset]::Now.ToString('o'); timezone = [TimeZoneInfo]::Local.Id
        base_url = $BaseUrl; source_state = 'uncommitted Week 15 working tree based on 133b0c8'; fixture = 'fictional example.test users and controlled records'
        passed = $passed; total = $results.Count; results = $results
    }
    $outputPath = Join-Path $RepositoryRoot 'submissions\week-15\tests\api-results.json'
    $output | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $outputPath -Encoding utf8
    if ($passed -ne $results.Count) { throw "$passed of $($results.Count) expected API results matched." }
    "PASS: $passed of $($results.Count) Week 15 API scenarios matched expected outcomes."
}
finally {
    $demoPassword = $null
    $client.Dispose()
    $handler.Dispose()
}
