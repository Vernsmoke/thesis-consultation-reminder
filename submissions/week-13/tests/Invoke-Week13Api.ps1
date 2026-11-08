param([string]$ApiBase = 'http://127.0.0.1:8000/api')
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$runAt = [DateTimeOffset]::UtcNow
$records = [System.Collections.Generic.List[object]]::new()
$passwordLine = Get-Content (Join-Path $repoRoot 'backend/.env') | Where-Object { $_ -match '^DEMO_PASSWORD=' } | Select-Object -First 1
if (!$passwordLine) { throw 'Missing private DEMO_PASSWORD. No credentials are written to evidence.' }
$fixturePassword = ($passwordLine -replace '^DEMO_PASSWORD=', '').Trim('"')
function Request-Case {
    param([string]$Name,[string]$Method,[string]$Path,[object]$Body,[string]$Token,[string]$Key,[int]$Expected)
    $headers = @{ Accept='application/json' }
    if($Token) { $headers.Authorization = 'Bearer '+$Token }
    if($Key) { $headers['Idempotency-Key']=$Key }
    $options = @{Uri=($ApiBase+$Path);Method=$Method;Headers=$headers;ContentType='application/json';SkipHttpErrorCheck=$true;TimeoutSec=10}
    if($null -ne $Body) { $options.Body=($Body | ConvertTo-Json -Compress) }
    $clock=[Diagnostics.Stopwatch]::StartNew()
    $response=Invoke-WebRequest @options
    $clock.Stop()
    $data=$response.Content | ConvertFrom-Json
    $safeBody=$Body
    $safeResponse=$data
    if($Path -eq '/login') { $safeBody=@{email=$Body.email;password='[omitted]'}; $safeResponse=@{user=$data.user;token='[omitted]'} }
    $records.Add([pscustomobject]@{scenario=$Name;executed_at_utc=[DateTimeOffset]::UtcNow.ToString('o');method=$Method;path=$Path;
        authenticated=[bool]$Token;idempotency_key=$Key;request=$safeBody;expected=$Expected;actual=[int]$response.StatusCode;
        passed=([int]$response.StatusCode -eq $Expected);elapsed_ms=$clock.ElapsedMilliseconds;correlation_id=[string]($response.Headers['X-Correlation-ID'] -join '');response=$safeResponse})
    if([int]$response.StatusCode -ne $Expected) { throw "Unexpected status in $Name; see sanitized record." }
    return $data
}
try {
    $null=Request-Case 'HTTP-01 unauthenticated' GET '/consultations' $null '' '' 401
    $student=Request-Case 'HTTP-02 student sign in' POST '/login' @{email='student@example.test';password=$fixturePassword} '' '' 200
    $adviser=Request-Case 'HTTP-03 adviser sign in' POST '/login' @{email='adviser@example.test';password=$fixturePassword} '' '' 200
    $coordinator=Request-Case 'HTTP-04 coordinator sign in' POST '/login' @{email='coordinator@example.test';password=$fixturePassword} '' '' 200
    $panel=Request-Case 'HTTP-05 panel sign in' POST '/login' @{email='panel@example.test';password=$fixturePassword} '' '' 200
    $null=Request-Case 'HTTP-06 invalid input' POST '/consultations' @{} $student.token '' 422
    $payload=@{agenda='Fictional consultation to review interview questions';scheduled_at=[DateTime]::UtcNow.AddHours(4).ToString('yyyy-MM-ddTHH:mm:ssZ');adviser_id=$adviser.user.id;panel_id=$panel.user.id}
    $key='http_'+[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $created=Request-Case 'HTTP-07 consultation created' POST '/consultations' $payload $student.token $key 201
    $null=Request-Case 'HTTP-08 duplicate replay' POST '/consultations' $payload $student.token $key 200
    $changed=$payload.Clone();$changed.agenda='Different fictional input under the same key'
    $null=Request-Case 'HTTP-09 changed payload conflict' POST '/consultations' $changed $student.token $key 409
    $id=$created.id
    $null=Request-Case 'HTTP-10 forbidden student confirmation' PATCH "/consultations/$id" @{status='confirmed'} $student.token '' 403
    $null=Request-Case 'HTTP-11 adviser confirms' PATCH "/consultations/$id" @{status='confirmed'} $adviser.token '' 200
    $action=Request-Case 'HTTP-12 action created' POST "/consultations/$id/actions" @{description='Revise the fictional interview questions';due_at=[DateTime]::UtcNow.AddDays(2).ToString('yyyy-MM-ddTHH:mm:ssZ')} $adviser.token '' 201
    $null=Request-Case 'HTTP-13 follow up completed' PATCH "/actions/$($action.id)/complete" @{} $student.token '' 200
    $null=Request-Case 'HTTP-14 meeting completed' PATCH "/consultations/$id" @{status='completed'} $adviser.token '' 200
    $null=Request-Case 'HTTP-15 assigned panel reads' GET '/consultations' $null $panel.token '' 200
    $null=Request-Case 'HTTP-16 coordinator manual queue' GET '/automation' $null $coordinator.token '' 200
    $null=Request-Case 'HTTP-17 student cannot read manual queue' GET '/automation' $null $student.token '' 403
    $null=Request-Case 'HTTP-18 not found' PATCH '/consultations/999999' @{status='confirmed'} $adviser.token '' 404
    foreach($session in @($student,$adviser,$coordinator,$panel)) { $null=Request-Case 'HTTP session logout' POST '/logout' @{} $session.token '' 200 }
} finally {
    $result=@{build='uncommitted Week 13 working tree';started_at_utc=$runAt.ToString('o');completed_at_utc=[DateTimeOffset]::UtcNow.ToString('o');transport='actual loopback HTTP API, separate from unavailable browser verification';records=$records}
    $result | ConvertTo-Json -Depth 16 | Set-Content (Join-Path $repoRoot 'submissions/week-13/tests/http-results.json')
    $fixturePassword=$null
}
Write-Output "Sanitized HTTP cases passed: $($records.Count). Tokens and passwords omitted."
