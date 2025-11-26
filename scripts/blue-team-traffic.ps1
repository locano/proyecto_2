# Ruta del archivo de logs
$LogPath = "C:\Logs\blue-team.log"

# Asegurar que el directorio exista
if (!(Test-Path "C:\Logs")) {
    New-Item -ItemType Directory -Path "C:\Logs" | Out-Null
}

Write-Output "=== Iniciando tráfico legítimo Blue Team ==="
Write-Output "Timestamp: $(Get-Date -Format u)"

$ENDPOINTS = @(
    "http://localhost:3000"
    "http://localhost:3000/#/login"
    "http://localhost:3000/rest/products/search?q=apple"
    "http://localhost:3000/rest/products/search?q=juice"
    "http://localhost:3000/api/Products"
)

foreach ($url in $ENDPOINTS) {

    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        $status = "OK"
        $code = $response.StatusCode
    } catch {
        $status = "ERROR"
        $code = $_.Exception.Response.StatusCode.value__
    }

    # Crear objeto JSON para Filebeat
    $logEntry = @{
        timestamp      = (Get-Date -Format "o")
        endpoint       = $url
        status         = $status
        response_code  = $code
        "fileset.name" = "blue-team"
        script         = "blue-team-traffic"
        host           = $env:COMPUTERNAME
    } | ConvertTo-Json -Compress

    # Guardar en el log
    Add-Content -Path $LogPath -Value $logEntry

    Write-Output "$(Get-Date -Format u) $status $url ($code)"

    Start-Sleep -Seconds 5
}

Write-Output "=== Tráfico legítimo completado ==="
Write-Output "Timestamp: $(Get-Date -Format u)"
