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
    param([string]$Method, [string]$Path, [object]$Body, [string]$Token)
    $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($Method), "$BaseUrl$Path")
    $request.Headers.Accept.ParseAdd('application/json')
    if ($Token) { $request.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $Token) }
    if ($null -ne $Body) {
        $json = $Body | ConvertTo-Json -Depth 12 -Compress
        $request.Content = [System.Net.Http.StringContent]::new($json, [Text.Encoding]::UTF8, 'application/json')
    }
    $response = $client.Send($request)
    $text = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    $parsed = if ($text) { $text | ConvertFrom-Json } else { $null }
    [pscustomobject]@{
        Status = [int]$response.StatusCode
        Correlation = if ($response.Headers.Contains('X-Correlation-ID')) { ($response.Headers.GetValues('X-Correlation-ID') | Select-Object -First 1) } else { $null }
        Body = $parsed
    }
}

function Sign-In([string]$Role) {
    $response = Invoke-ControlledApi POST '/login' @{ email = "$Role@example.test"; password = $demoPassword } $null
    if ($response.Status -ne 200) { throw "Controlled $Role sign-in failed with HTTP $($response.Status)." }
    $response.Body.token
}

function New-Envelope([string]$CoordinatorToken) {
    $response = Invoke-ControlledApi POST '/secure-exchange/envelopes' @{ consultation_id = 4 } $CoordinatorToken
    if ($response.Status -ne 201) { throw "Envelope creation failed with HTTP $($response.Status)." }
    $response.Body.envelope
}

try {
    $coordinatorToken = Sign-In 'coordinator'
    $adviserToken = Sign-In 'adviser'
    $panelToken = Sign-In 'panel'
    $results = [System.Collections.Generic.List[object]]::new()

    $accepted = New-Envelope $coordinatorToken
    $response = Invoke-ControlledApi POST '/secure-exchange/receive' $accepted $adviserToken
    $results.Add([pscustomobject]@{ id = 'SEC-HTTP-01'; scenario = 'authenticated envelope accepted'; expected = 200; actual = $response.Status; message = $response.Body.message; correlation_id = $response.Correlation; time = [DateTimeOffset]::Now.ToString('o') })
    $response = Invoke-ControlledApi POST '/secure-exchange/receive' $accepted $adviserToken
    $results.Add([pscustomobject]@{ id = 'SEC-HTTP-02'; scenario = 'replay rejected'; expected = 409; actual = $response.Status; message = $response.Body.message; correlation_id = $response.Correlation; time = [DateTimeOffset]::Now.ToString('o') })

    $tampered = New-Envelope $coordinatorToken
    $chars = $tampered.ciphertext.ToCharArray()
    $chars[4] = if ($chars[4] -eq 'A') { 'B' } else { 'A' }
    $tampered.ciphertext = -join $chars
    $response = Invoke-ControlledApi POST '/secure-exchange/receive' $tampered $adviserToken
    $results.Add([pscustomobject]@{ id = 'SEC-HTTP-03'; scenario = 'altered ciphertext rejected'; expected = 422; actual = $response.Status; message = $response.Body.message; correlation_id = $response.Correlation; time = [DateTimeOffset]::Now.ToString('o') })

    $unauthorized = New-Envelope $coordinatorToken
    $response = Invoke-ControlledApi POST '/secure-exchange/receive' $unauthorized $panelToken
    $results.Add([pscustomobject]@{ id = 'SEC-HTTP-04'; scenario = 'unauthorized role rejected'; expected = 403; actual = $response.Status; message = $response.Body.message; correlation_id = $response.Correlation; time = [DateTimeOffset]::Now.ToString('o') })

    $response = Invoke-ControlledApi POST '/secure-exchange/receive' @{} $adviserToken
    $results.Add([pscustomobject]@{ id = 'SEC-HTTP-05'; scenario = 'invalid envelope rejected'; expected = 422; actual = $response.Status; message = $response.Body.message; correlation_id = $response.Correlation; time = [DateTimeOffset]::Now.ToString('o') })

    $uiEnvelope = New-Envelope $coordinatorToken
    $uiPath = Join-Path $RepositoryRoot 'tmp\week-14-ui-envelope.json'
    $uiEnvelope | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $uiPath -Encoding utf8

    $passed = @($results | Where-Object { $_.expected -eq $_.actual }).Count
    $output = [pscustomobject]@{
        executed_at = [DateTimeOffset]::Now.ToString('o')
        timezone = [TimeZoneInfo]::Local.Id
        base_url = $BaseUrl
        source_state = 'uncommitted Week 14 working tree based on v1.0.0 (707ef93)'
        envelope_summary = [pscustomobject]@{ algorithm = 'AES-256-GCM'; ciphertext_logged = $false; key_logged = $false; ttl_seconds = 300 }
        passed = $passed
        total = $results.Count
        results = $results
    }
    $outputPath = Join-Path $RepositoryRoot 'submissions\week-14\tests\http-security-results.json'
    $output | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $outputPath -Encoding utf8
    if ($passed -ne $results.Count) { throw "$passed of $($results.Count) expected HTTP results matched." }
    "PASS: $passed of $($results.Count) HTTPS security scenarios matched expected outcomes."
}
finally {
    $demoPassword = $null
    $client.Dispose()
    $handler.Dispose()
}
