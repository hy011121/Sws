<#
.NOTES
    Author: cBot01
    Version: 2.0
#>

Write-Host @"

 ██████╗██████╗  ██████╗ ████████╗ ██╗ █████╗ ██████╗ 
██╔════╝██╔══██╗██╔═══██╗╚══██╔══╝███║██╔══██╗╚════██╗
██║     ██████╔╝██║   ██║   ██║   ╚██║╚██████║ █████╔╝
██║     ██╔══██╗██║   ██║   ██║    ██║ ╚═══██║██╔═══╝ 
╚██████╗██████╔╝╚██████╔╝   ██║    ██║ █████╔╝███████╗
 ╚═════╝╚═════╝  ╚═════╝    ╚═╝    ╚═╝ ╚════╝ ╚══════╝
                                         v2 :: Edition                                                      
                                                      
                                                                            
"@ -ForegroundColor Cyan

$webshellPaths = @(
    "shell.php", "cmd.php", "wso.php", "r57.php", "c99.php", "b374k.php", "mini.php", "1.php", "up.php",
    "upload.php", "uploads.php", "backdoor.php", "admin.php", "root.php", "hack.php", "exploit.php", 
    "gate.php", "config.php", "connect.php", "webadmin.php", "access.php", "index2.php", "mailer.php", 
    "mailer2.php", "mail.php", "eval.php", "execute.php", "code.php", "system.php", "lol.php", 
    "phpinfo.php", "passthru.php", "alfa.php", "fox.php", "test.php", "safe.php", "secure.php", 
    "error.php", "debug.php", "core.php", "logger.php", "injection.php", "inject.php", "bot.php", 
    "sniper.php", "controller.php", "z3ro.php", "0day.php", "panel.php", "dashboard.php", "console.php", 
    "monitor.php", "shellex.php", "wsh.php", "p0wn.php", "admin123.php", "superadmin.php", "info.php", 
    "remote.php", "proc.php", "sys.php", "dark.php", "darkness.php", "uploader.php", "upfile.php", 
    "upl.php", "sh.php", "shadow.php", "magic.php", "webshell.php", "cmdshell.php", "phpshell.php", 
    "evil.php", "god.php", "h4x0r.php", "sqli.php", "fakeshell.php", "invisible.php", "myadmin.php", 
    "siteadmin.php", "login.php", "webadmin2.php", "newadmin.php", "data.php", "new.php", "old.php", 
    "update.php", "upgrade.php", "xpl.php", "expl.php", "phpcmd.php", "cli.php", "shell123.php", 
    "remoteshell.php", "remoteaccess.php", "vuln.php", "kill.php", "nmap.php", "systeminfo.php", 
    "ping.php", "traceroute.php", "check.php"
)

$commonDirs = @(
    "", "admin", "uploads", "upload", "wp-content", "wp-content/uploads", "wp-content/themes",
    "wp-content/plugins", "wp-content/plugins/contact-form-7", "wp-includes", "wp-admin", "wp-config",
    "images", "assets", "css", "js", "js/vendor", "media", "media/images", "files", "includes", "inc",
    "temp", "tmp", "cache", "backup", "backups", "storage", "storage/logs", "log", "logs", "core",
    "core/vendor", "vendor", "framework", "system", "system/cache", "hidden", "secrets", ".ftp", ".old",
    ".oldsite", ".bak", "_dev", "_private", "hidden_uploads", "tmp/uploads", "modules", "controllers",
    "components", "lib", "libs", "library", "engine", "data", "cgi-bin", "webadmin", "portal", "site",
    "panel", "console", "phpmyadmin", "new", "old", "test", "testing", "misc", "public", "server",
    "conf", "confidential", "error", "api", "cgi", "mail", "mails", "mailer", "adminer", "scripts",
    "admin-area", "cms", "dashboard", "uploads/temp", "upload/files", "themes/default",
    "themes/twentyseventeen", "themes/twentytwenty"
)

$domains = Get-Content -Path ".\domains.txt"
$results = @()

Write-Host "Starting mass webshell scan..." -ForegroundColor Cyan

foreach ($domain in $domains) {
    foreach ($dir in $commonDirs) {
        foreach ($file in $webshellPaths) {
            $path = if ($dir -eq "") { $file } else { "$dir/$file" }
            $url = "$($domain.TrimEnd('/'))/$path"
            try {
                $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 5
                if ($response.StatusCode -eq 200) {
                    if ($response.Content -match "WSO|R57|C99|cmd|shell|eval|backdoor") {
                        Write-Host "[+] Webshell detected: $url" -ForegroundColor Green
                        $results += "[SUSPECT] $url"
                    } else {
                        Write-Host "[-] Accessible, check manually: $url" -ForegroundColor Yellow
                        $results += "[CHECK] $url"
                    }
                }
            } catch {
                Write-Host "[X] Not found or error: $url" -ForegroundColor Red
            }
        }
    }
}

$results | Set-Content -Path ".\scan_results.txt"
Write-Host "`nScan completed. Results saved to scan_results.txt" -ForegroundColor Cyan
