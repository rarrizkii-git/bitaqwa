#Requires -Version 5.1
<#
.SYNOPSIS
    Bitaqwa routing verification matrix (PWA Phase 2A).

.DESCRIPTION
    Verifies SPA deep-link routing and static-asset handling against either:

      -Local
          Serves <repo>/build/web with Vercel-equivalent routing semantics
          on a loopback listener, then runs the matrix over HTTP. Run
          `flutter build web --release` first.

      -BaseUrl <url>
          Runs the same matrix against a live deployment (Vercel preview
          or production). Intended for the Phase 2A preview gate and
          Phase 2E.

    Semantics replicated from @vercel/routing-utils getTransformedRoutes()
    and confirmed empirically against the live platform:
      1. No trailing-slash normalization: with `trailingSlash` undefined,
         Vercel routes "/quran/" as-is (no 308); SPA routes with a
         trailing slash get the shell, asset directories 404.
      2. Filesystem first: existing files are always served; rewrites never
         shadow them (`handle: filesystem` precedes rewrite routes).
      3. Rewrites match the request path only, anchored as ^<source>$
         (case-sensitive); query strings are preserved and ignored by
         route matching.
    Static content types mirror what Vercel actually serves
    (.js -> application/javascript, .json -> application/json, .otf -> font/otf).

    The rewrite pattern under test is read from vercel.json so this script
    always verifies exactly what will be deployed.

.EXAMPLE
    pwsh -File tool/verify_routing.ps1 -Local

.EXAMPLE
    pwsh -File tool/verify_routing.ps1 -BaseUrl https://bitaqwa.vercel.app
#>
[CmdletBinding()]
param(
    # Live deployment to verify (e.g. a Vercel preview URL or production).
    [string]$BaseUrl = '',

    # Serve <repo>/build/web locally with Vercel-equivalent routing.
    [switch]$Local,

    # Build output to serve in -Local mode. Defaults to <repo>/build/web.
    [string]$WebRoot = '',

    # Optional Vercel "Protection Bypass for Automation" secret
    # (Project Settings > Domains > Deployment Protection). Sent as the
    # x-vercel-protection-bypass header so the matrix can run against
    # preview deployments using Standard Protection.
    [string]$ProtectionBypass = ''
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Resolve paths and read the deployed rewrite (single source of truth)
# ---------------------------------------------------------------------------

$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not $WebRoot) { $WebRoot = Join-Path $RepoRoot 'build\web' }
$VercelJsonPath = Join-Path $RepoRoot 'vercel.json'

if (-not (Test-Path -LiteralPath $VercelJsonPath)) {
    throw "vercel.json not found: $VercelJsonPath"
}
$vercel = Get-Content -Raw -LiteralPath $VercelJsonPath | ConvertFrom-Json
$rewrite = @($vercel.rewrites)[0]
if (-not $rewrite) { throw 'vercel.json does not define any rewrites.' }
$SourcePattern = [string]$rewrite.source
$Destination = [string]$rewrite.destination

Write-Host 'vercel.json rewrite'
Write-Host "  source      : $SourcePattern"
Write-Host "  destination : $Destination"
Write-Host ''

# path-only, anchored, case-sensitive - mirrors @vercel/routing-utils
$RouteRegexSource = '^' + $SourcePattern + '$'

# ---------------------------------------------------------------------------
# Verification matrix
#   Html      -> 200, text/html, SPA shell signature ('bitaqwa-splash')
#   File      -> 200, exact content type, never the SPA shell
#   NotFound  -> 404 (missing assets must NOT return the SPA shell)
#   Redirect  -> 308 to the slash-free path (trailing-slash normalization)
# ---------------------------------------------------------------------------

$Matrix = @(
    # -- SPA routes (all go_router routes incl. deep links + unknown) -----
    @{ Path = '/';                                   Expect = 'Html' }
    @{ Path = '/jadwal-shalat';                      Expect = 'Html' }
    @{ Path = '/quran';                              Expect = 'Html' }
    @{ Path = '/quran/36';                           Expect = 'Html' }
    @{ Path = '/quran/112';                          Expect = 'Html' }
    @{ Path = '/doa';                                Expect = 'Html' }
    @{ Path = '/zikir';                              Expect = 'Html' }
    @{ Path = '/kiblat';                            Expect = 'Html' }
    @{ Path = '/zakat';                              Expect = 'Html' }
    @{ Path = '/pengaturan';                         Expect = 'Html' }
    @{ Path = '/kajian';                             Expect = 'Html' }
    @{ Path = '/kajian/tersimpan';                   Expect = 'Html' }
    @{ Path = '/kajian/ustadz';                      Expect = 'Html' }
    @{ Path = '/kajian/ustadz/khalid-basalamah';     Expect = 'Html' }
    @{ Path = '/kajian/ustadz/ammi-nur-baits';       Expect = 'Html' }
    @{ Path = '/kajian/kategori/tafsir';             Expect = 'Html' }
    @{ Path = '/kajian/kategori/tazkiyah';           Expect = 'Html' }
    @{ Path = '/kajian/tauhid-jalan-keselamatan';    Expect = 'Html' }
    @{ Path = '/not-a-route';                        Expect = 'Html' }
    @{ Path = '/quran?ref=shortcut';                 Expect = 'Html' }   # query preserved, path-only matching

    # -- existing static files (must be served, never rewritten) ----------
    @{ Path = '/index.html';                         Expect = 'File'; Type = 'text/html' }        # shell itself, served from filesystem
    @{ Path = '/main.dart.js';                       Expect = 'File'; Type = 'application/javascript' }
    @{ Path = '/flutter.js';                         Expect = 'File'; Type = 'application/javascript' }
    @{ Path = '/flutter_bootstrap.js';              Expect = 'File'; Type = 'application/javascript' }
    @{ Path = '/flutter_service_worker.js';         Expect = 'File'; Type = 'application/javascript' }
    @{ Path = '/canvaskit/canvaskit.js';            Expect = 'File'; Type = 'application/javascript' }
    @{ Path = '/canvaskit/canvaskit.wasm';          Expect = 'File'; Type = 'application/wasm' }
    @{ Path = '/canvaskit/chromium/canvaskit.wasm';  Expect = 'File'; Type = 'application/wasm' }
    @{ Path = '/canvaskit/skwasm.js';                Expect = 'File'; Type = 'application/javascript' }
    @{ Path = '/assets/FontManifest.json';           Expect = 'File'; Type = 'application/json' }
    @{ Path = '/assets/AssetManifest.bin';          Expect = 'File'; Type = 'application/octet-stream' }
    @{ Path = '/assets/AssetManifest.bin.json';      Expect = 'File'; Type = 'application/json' }
    @{ Path = '/assets/fonts/MaterialIcons-Regular.otf'; Expect = 'File'; Type = 'font/otf' }
    @{ Path = '/assets/NOTICES';                     Expect = 'File'; Type = 'application/octet-stream' }  # extensionless file under assets/ - exercises the prefix exclusion
    @{ Path = '/icons/Icon-192.png';                 Expect = 'File'; Type = 'image/png' }
    @{ Path = '/icons/Icon-maskable-512.png';       Expect = 'File'; Type = 'image/png' }
    @{ Path = '/manifest.json';                      Expect = 'File'; Type = 'application/json' }
    @{ Path = '/favicon.png';                        Expect = 'File'; Type = 'image/png' }
    @{ Path = '/favicon-32.png';                     Expect = 'File'; Type = 'image/png' }
    @{ Path = '/apple-touch-icon.png';              Expect = 'File'; Type = 'image/png' }
    @{ Path = '/robots.txt';                         Expect = 'File'; Type = 'text/plain' }
    @{ Path = '/version.json';                       Expect = 'File'; Type = 'application/json' }

    # -- missing assets (must 404, not silently return the SPA shell) -----
    @{ Path = '/main.dart.js.typo';                 Expect = 'NotFound' }
    @{ Path = '/missing/asset.png';                  Expect = 'NotFound' }
    @{ Path = '/assets/nope.json';                   Expect = 'NotFound' }
    @{ Path = '/icons/Icon-999.png';                 Expect = 'NotFound' }
    @{ Path = '/canvaskit/missing.wasm';            Expect = 'NotFound' }
    @{ Path = '/nope.js';                            Expect = 'NotFound' }
    @{ Path = '/missing/deep/path.html';             Expect = 'NotFound' }

    # -- trailing-slash URLs (Vercel does NOT normalize by default) --------
    @{ Path = '/quran/';                             Expect = 'Html' }
    @{ Path = '/kajian/ustadz/khalid-basalamah/';   Expect = 'Html' }
    @{ Path = '/icons/';                             Expect = 'NotFound' }
    @{ Path = '/canvaskit/';                         Expect = 'NotFound' }
    @{ Path = '/assets/';                            Expect = 'NotFound' }
)

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

$ShellSignature = 'bitaqwa-splash'

function Read-BodyPrefix {
    param($Stream, [int]$MaxBytes = 32768)
    if ($null -eq $Stream) { return '' }
    try {
        $buffer = New-Object byte[] $MaxBytes
        $total = 0
        while ($total -lt $MaxBytes) {
            $read = $Stream.Read($buffer, $total, $MaxBytes - $total)
            if ($read -le 0) { break }
            $total += $read
        }
        if ($total -le 0) { return '' }
        return [System.Text.Encoding]::ASCII.GetString($buffer, 0, $total)
    } finally {
        $Stream.Dispose()
    }
}

function Get-PathFromLocation {
    param([string]$Location)
    if (-not $Location) { return '' }
    if ($Location -match '^https?://') {
        try { return ([Uri]$Location).PathAndQuery } catch { return $Location }
    }
    return $Location
}

function Compare-ContentType {
    param([string]$Actual, [string]$Expected)
    if (-not $Actual) { return $false }
    $base = ($Actual -split ';')[0].Trim()
    return ($base -ieq $Expected)
}

# ---------------------------------------------------------------------------
# Local Vercel-equivalent server
# ---------------------------------------------------------------------------

$ServerScript = {
    param(
        [string]$Root,
        [string]$Prefix,
        [string]$RouteSource,
        [string]$IndexHtml
    )

    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add($Prefix)
    $listener.Start()
    $route = [regex]::new($RouteSource)  # case-sensitive by default

    $contentTypes = @{
        '.html'    = 'text/html; charset=utf-8'
        '.js'      = 'application/javascript; charset=utf-8'
        '.mjs'     = 'application/javascript; charset=utf-8'
        '.json'    = 'application/json; charset=utf-8'
        '.map'     = 'application/json; charset=utf-8'
        '.png'     = 'image/png'
        '.svg'     = 'image/svg+xml'
        '.wasm'    = 'application/wasm'
        '.otf'     = 'font/otf'
        '.ttf'     = 'font/ttf'
        '.txt'     = 'text/plain; charset=utf-8'
        '.bin'     = 'application/octet-stream'
        '.symbols' = 'application/octet-stream'
    }
    function Get-TypeFor([string]$FileName) {
        $ext = [System.IO.Path]::GetExtension($FileName)
        if ($contentTypes.ContainsKey($ext)) { return $contentTypes[$ext] }
        return 'application/octet-stream'
    }

    $rootFull = [System.IO.Path]::GetFullPath($Root)
    try {
        :loop while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            try {
                $path = $request.Url.AbsolutePath

                if ($path -eq '/__verify_stop__') {
                    $response.StatusCode = 200
                    $response.ContentType = 'text/plain'
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes('stopped')
                    $response.ContentLength64 = $bytes.Length
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                    $response.Close()
                    break :loop
                }

                # 1. Filesystem first.
                $file = $null
                if ($path -eq '/') {
                    $file = $IndexHtml
                }
                else {
                    $rel = ($path.TrimStart('/')) -replace '/', [System.IO.Path]::DirectorySeparatorChar
                    $candidate = [System.IO.Path]::GetFullPath((Join-Path $rootFull $rel))
                    if ($candidate.StartsWith($rootFull) -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
                        $file = $candidate
                    }
                }
                if ($file) {
                    $bytes = [System.IO.File]::ReadAllBytes($file)
                    $response.StatusCode = 200
                    $response.ContentType = Get-TypeFor $file
                    $response.ContentLength64 = $bytes.Length
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                    $response.Close()
                    continue :loop
                }

                # 2. Rewrite (path-only, anchored, case-sensitive).
                if ($route.IsMatch($path)) {
                    $bytes = [System.IO.File]::ReadAllBytes($IndexHtml)
                    $response.StatusCode = 200
                    $response.ContentType = 'text/html; charset=utf-8'
                    $response.ContentLength64 = $bytes.Length
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                    $response.Close()
                    continue :loop
                }

                # 3. Not found.
                $response.StatusCode = 404
                $response.Close()
            }
            catch {
                try { $response.StatusCode = 500; $response.Close() } catch { }
            }
        }
    }
    finally {
        if ($listener.IsListening) { $listener.Stop() }
        $listener.Close()
    }
}

# ---------------------------------------------------------------------------
# HTTP matrix runner
# ---------------------------------------------------------------------------

Add-Type -AssemblyName System.Net.Http

function Invoke-Matrix {
    param([string]$Base, [string]$ModeLabel)

    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(30)
    if ($script:ProtectionBypassSecret) {
        $client.DefaultRequestHeaders.Add('x-vercel-protection-bypass', $script:ProtectionBypassSecret)
    }

    $results = New-Object System.Collections.Generic.List[object]
    try {
        foreach ($check in $Matrix) {
            $url = "$Base$($check.Path)"
            $detail = ''
            $ok = $false
            try {
                $response = $client.GetAsync($url).GetAwaiter().GetResult()
                $status = [int]$response.StatusCode
                $contentType = ''
                if ($response.Content.Headers.ContentType) {
                    $contentType = $response.Content.Headers.ContentType.ToString()
                }
                $bodyPrefix = Read-BodyPrefix $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
                $location = ''
                if ($response.Headers.Location) { $location = $response.Headers.Location.ToString() }

                switch ($check.Expect) {
                    'Html' {
                        $ok = ($status -eq 200) -and
                            ($contentType -like 'text/html*') -and
                            ($bodyPrefix.Contains($ShellSignature))
                        $detail = "status=$status type=$contentType signature=$($bodyPrefix.Contains($ShellSignature))"
                    }
                    'File' {
                        $ok = ($status -eq 200) -and
                            (Compare-ContentType -Actual $contentType -Expected $check.Type) -and
                            ($bodyPrefix.Length -gt 0) -and
                            (($check.Type -like 'text/html*') -or (-not $bodyPrefix.Contains($ShellSignature)))
                        $detail = "status=$status type=$contentType shellLeak=$($bodyPrefix.Contains($ShellSignature))"
                    }
                    'NotFound' {
                        $ok = ($status -eq 404)
                        $detail = "status=$status"
                    }
                    'Redirect' {
                        $locPath = Get-PathFromLocation $location
                        $ok = ($status -in 301, 307, 308) -and ($locPath -eq $check.Location)
                        $detail = "status=$status location=$locPath"
                    }
                    default {
                        $ok = $false
                        $detail = "unknown expectation: $($check.Expect)"
                    }
                }
            }
            catch {
                $ok = $false
                $status = 0
                $detail = "request failed: $($_.Exception.Message)"
            }

            $state = if ($ok) { 'PASS' } else { 'FAIL' }
            $results.Add([pscustomobject]@{
                State   = $state
                Expect  = $check.Expect
                Path    = $check.Path
                Detail  = $detail
                Mode    = $ModeLabel
            })
        }
    }
    finally {
        $client.Dispose()
        $handler.Dispose()
    }
    return $results
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if (-not $Local -and -not $BaseUrl) {
    throw "Specify either -Local or -BaseUrl <url>."
}
if ($Local -and $BaseUrl) {
    throw "Use either -Local or -BaseUrl, not both."
}

if ($ProtectionBypass) {
    $script:ProtectionBypassSecret = $ProtectionBypass
    Write-Host "Sending x-vercel-protection-bypass header (Protection Bypass for Automation)."
}

$allResults = New-Object System.Collections.Generic.List[object]

if ($Local) {
    if (-not (Test-Path -LiteralPath $WebRoot)) {
        throw "Web root not found: $WebRoot - run 'flutter build web --release' first."
    }
    $indexHtml = Join-Path $WebRoot 'index.html'
    if (-not (Test-Path -LiteralPath $indexHtml -PathType Leaf)) {
        throw "index.html not found in $WebRoot - run 'flutter build web --release' first."
    }

    # Phase 2A pre-flight: the Netlify-style _redirects file must be gone
    # from both the source tree and the current build output.
    foreach ($legacy in @((Join-Path $RepoRoot 'web\_redirects'), (Join-Path $WebRoot '_redirects'))) {
        if (Test-Path -LiteralPath $legacy) {
            throw "Legacy Netlify-style file still present: $legacy (delete it and rebuild)."
        }
    }

    # Pick a free loopback port.
    $portProbe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    $portProbe.Start()
    $port = ([System.Net.IPEndPoint]$portProbe.LocalEndpoint).Port
    $portProbe.Stop()

    $prefix = "http://127.0.0.1:$port/"
    Write-Host "Serving $WebRoot on $prefix with Vercel-equivalent routing..."

    $server = [System.Management.Automation.PowerShell]::Create()
    $null = $server.AddScript($ServerScript.ToString())
    $null = $server.AddArgument([System.IO.Path]::GetFullPath($WebRoot))
    $null = $server.AddArgument($prefix)
    $null = $server.AddArgument($RouteRegexSource)
    $null = $server.AddArgument([System.IO.Path]::GetFullPath($indexHtml))
    $serverTask = $server.BeginInvoke()

    try {
        # Wait for readiness.
        $ready = $false
        $deadline = [DateTime]::UtcNow.AddSeconds(15)
        while ([DateTime]::UtcNow -lt $deadline) {
            try {
                $probe = [System.Net.Http.HttpClient]::new()
                $probe.Timeout = [TimeSpan]::FromSeconds(2)
                $resp = $probe.GetAsync("$prefix" + '/').GetAwaiter().GetResult()
                $probe.Dispose()
                if ([int]$resp.StatusCode -eq 200) { $ready = $true; break }
            }
            catch { Start-Sleep -Milliseconds 250 }
        }
        if (-not $ready) {
            if ($server.HadErrors) {
                $server.Streams.Error | ForEach-Object { Write-Error $_ }
            }
            throw 'Local server did not become ready within 15 seconds.'
        }

        $allResults.AddRange((Invoke-Matrix -Base $prefix.TrimEnd('/') -ModeLabel "local:$port"))
    }
    finally {
        # Signal the server to stop, then reap the runspace.
        try {
            $stopper = [System.Net.Http.HttpClient]::new()
            $stopper.Timeout = [TimeSpan]::FromSeconds(5)
            $null = $stopper.GetAsync("$prefix" + '/__verify_stop__').GetAwaiter().GetResult()
            $stopper.Dispose()
        }
        catch { }
        try { $null = $server.EndInvoke($serverTask) } catch { }
        if ($server.HadErrors) {
            $server.Streams.Error | ForEach-Object { Write-Warning "server: $_" }
        }
        $server.Dispose()
    }
}
else {
    $base = $BaseUrl.TrimEnd('/')
    $allResults.AddRange((Invoke-Matrix -Base $base -ModeLabel "remote"))
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host '===== Routing verification matrix ====='
foreach ($r in $allResults) {
    $line = '{0}  {1,-8} {2}' -f $r.State, $r.Expect, $r.Path
    if ($r.State -eq 'FAIL') { $line += "  -> $($r.Detail)" }
    Write-Host $line
}

$failed = @($allResults | Where-Object { $_.State -eq 'FAIL' })
$passed = @($allResults | Where-Object { $_.State -eq 'PASS' })
Write-Host ''
Write-Host ("Summary: {0} passed, {1} failed, {2} total" -f $passed.Count, $failed.Count, $allResults.Count)

if ($failed.Count -gt 0) {
    Write-Host ''
    Write-Host 'Failures:'
    foreach ($f in $failed) {
        Write-Host ("  {0} {1} {2} -> {3}" -f $f.Mode, $f.Expect, $f.Path, $f.Detail)
    }
    exit 1
}
exit 0
