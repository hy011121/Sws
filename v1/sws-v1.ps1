<#
.DESCRIPTION
    This script scans multiple domains/websites for potential webshell files
    by checking common webshell patterns, suspicious file extensions, and known signatures.
.NOTES
    Author: cBot01
    Version: 1.8.9
#>

# Parameters
param (
    [string]$DomainList,
    [string]$OutputFile = "webshell_scan_results.csv",
    [switch]$Verbose
)

Write-Host @"

 ██████╗██████╗  ██████╗ ████████╗ ██╗ █████╗ ██████╗ 
██╔════╝██╔══██╗██╔═══██╗╚══██╔══╝███║██╔══██╗╚════██╗
██║     ██████╔╝██║   ██║   ██║   ╚██║╚██████║ █████╔╝
██║     ██╔══██╗██║   ██║   ██║    ██║ ╚═══██║██╔═══╝ 
╚██████╗██████╔╝╚██████╔╝   ██║    ██║ █████╔╝███████╗
 ╚═════╝╚═════╝  ╚═════╝    ╚═╝    ╚═╝ ╚════╝ ╚══════╝
                                         v1 :: Edition                                                      
                                                                            
"@ -ForegroundColor Cyan
if (-not $DomainList) {
    Write-Host "[!] Error: Please provide a file containing list of domains (-DomainList domains.txt)" -ForegroundColor Red
    Write-Host "Usage: .\swsv1.ps1 -DomainList domains.txt [-OutputFile results.csv] [-Verbose]"
    exit
}

if (-not (Test-Path $DomainList)) {
    Write-Host "[!] Error: Domain list file not found: $DomainList" -ForegroundColor Red
    exit
}

$webshellPatterns = @(
    "eval\(.*\)",
    "base64_decode",
    "shell_exec",
    "passthru",
    "system\(",
    "exec\(",
    "popen\(",
    "proc_open",
    "assert\(",
    "create_function",
    "phpinfo\(\)",
    "wscript\.shell",
    "cmd\.exe",
    "powershell",
    "new ActiveXObject",
    "document\.write\(unescape\("
)


$suspiciousExtensions = @(
    ".php", ".phtml", ".phar", ".php3", ".php4", ".php5", ".php7", 
    ".asp", ".aspx", ".ashx", ".asmx", ".jsp", ".jspx",
    ".pl", ".cgi", ".py", ".sh", ".exe", ".bat", ".cmd",
    ".war", ".jar", ".gz", ".zip", ".rar"
)


$commonWebshellNames = @(
    "shell.php", "cmd.php", "b374k.php", "c99.php", "r57.php",
    "wso.php", "locus7shell.php", "minishell.php", "sym.php",
    "upload.php", "filemanager.php", "admin.php", "config.php",
    "xx.php", "xd.php", "404.php", "error.php", "tmp.php",
    "backdoor.php", "hacker.php", "evil.php", "test.php"
)


function Scan-WebShell {
    param (
        [string]$url
    )

    try {

        if (-not $url.StartsWith("http")) {
            $url = "http://" + $url
        }

        if ($Verbose) {
            Write-Host "[*] Scanning: $url" -ForegroundColor Yellow
        }

        $response = Invoke-WebRequest -Uri $url -Method Get -ErrorAction SilentlyContinue

        $contentMatches = @()
        foreach ($pattern in $webshellPatterns) {
            if ($response.Content -match $pattern) {
                $contentMatches += $pattern
            }
        }

        $suspiciousLinks = @()
        $links = $response.Links | Where-Object { $_.href -ne $null -and $_.href -ne "" }
        
        foreach ($link in $links) {
            $href = $link.href
            
            foreach ($ext in $suspiciousExtensions) {
                if ($href -like "*$ext") {
                    $suspiciousLinks += $href
                    break
                }
            }
            
            foreach ($name in $commonWebshellNames) {
                if ($href -like "*$name") {
                    $suspiciousLinks += $href
                    break
                }
            }
        }

        $result = [PSCustomObject]@{
            Domain = $url
            Status = $response.StatusCode
            ContentMatches = ($contentMatches -join ", ")
            SuspiciousLinks = ($suspiciousLinks -join ", ")
            PotentialWebShell = ($contentMatches.Count -gt 0 -or $suspiciousLinks.Count -gt 0)
        }

        return $result
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.Value__
        if (-not $statusCode) { $statusCode = "Connection Failed" }
        
        return [PSCustomObject]@{
            Domain = $url
            Status = $statusCode
            ContentMatches = ""
            SuspiciousLinks = ""
            PotentialWebShell = "N/A (Error)"
        }
    }
}

Write-Host "[+] Starting WebShell Scan" -ForegroundColor Green
Write-Host "[+] Domains to scan: $(Get-Content $DomainList | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Green
Write-Host "[+] Output file: $OutputFile" -ForegroundColor Green

$domains = Get-Content $DomainList
$results = @()

foreach ($domain in $domains) {
    $domain = $domain.Trim()
    if (-not [string]::IsNullOrEmpty($domain)) {
        $result = Scan-WebShell -url $domain
        $results += $result
        

        if ($result.PotentialWebShell -eq $true) {
            Write-Host "[!] Potential webshell found on: $domain" -ForegroundColor Red
            Write-Host "    Matches: $($result.ContentMatches)" -ForegroundColor DarkYellow
            Write-Host "    Suspicious Links: $($result.SuspiciousLinks)" -ForegroundColor DarkYellow
        }
        elseif ($Verbose) {
            Write-Host "[+] Scan completed for: $domain" -ForegroundColor Green
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "[+] Scan completed. Results saved to $OutputFile" -ForegroundColor Green
Write-Host "[+] Total domains scanned: $($results.Count)" -ForegroundColor Green
Write-Host "[+] Potential webshells found: $(($results | Where-Object { $_.PotentialWebShell -eq $true }).Count)" -ForegroundColor Red
