param(
    [ValidateSet('version','import','run','test','export','verify')]
    [string]$Task = 'verify'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $projectRoot
$godotExe = $env:GODOT_BIN
if (-not $godotExe) {
    $found = Get-Command godot -ErrorAction SilentlyContinue
    if ($found) { $godotExe = $found.Source }
}
if (-not $godotExe -or -not (Test-Path -LiteralPath $godotExe)) {
    throw 'Define GODOT_BIN con la ruta de tu Godot 4.7.2 existente.'
}
New-Item -ItemType Directory -Force build | Out-Null
function Invoke-Godot([string[]]$Arguments) {
    & $godotExe --path $projectRoot --log-file "$projectRoot/build/godot.log" @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Godot fallo: $LASTEXITCODE" }
    if ((Test-Path build/godot.log) -and (Select-String -Path build/godot.log -Pattern 'SCRIPT ERROR:|Parse Error:' -Quiet)) {
        throw 'Godot registro errores de scripts.'
    }
}
switch ($Task) {
    'version' { & $godotExe --headless --version }
    'import' { Invoke-Godot @('--headless','--editor','--import') }
    'run' { Invoke-Godot @() }
    'test' {
        Invoke-Godot @('--headless','--script','res://tests/run_tests.gd')
        Invoke-Godot @('--headless','--script','res://tests/smoke_scene.gd')
    }
    'export' {
        New-Item -ItemType Directory -Force build/web | Out-Null
        Invoke-Godot @('--headless','--export-release','Web','build/web/index.html')
        python scripts/check_web_export.py build/web
        if ($LASTEXITCODE -ne 0) { throw 'La exportacion web no cumple el requisito sin hilos.' }
    }
    'verify' {
        & $PSCommandPath import
        & $PSCommandPath test
        & $PSCommandPath export
    }
}
