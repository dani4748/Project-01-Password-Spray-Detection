$startTime = (Get-Date).AddHours(-1)

$events = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = $startTime
} -ErrorAction SilentlyContinue

$grouped = $events | Group-Object {
    ($_.Message | Select-String 'Source Network Address:\s+(\S+)').Matches.Value
} | Where-Object { $_.Count -ge 3 } | Sort-Object Count -Descending

if ($grouped) {
    Write-Host "ALERT: Password Spray Detected!" -ForegroundColor Red
    foreach ($g in $grouped) {
        Write-Host "Source: $($g.Name) | Attempts: $($g.Count)" -ForegroundColor Yellow
    }
} else {
    Write-Host "No spray pattern found." -ForegroundColor Green
}