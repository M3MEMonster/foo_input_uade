#Requires -Version 7.2
$ErrorActionPreference = "Stop"
$ComponentName = "foo_input_uade"
$DllName = "$ComponentName.dll"
$CoreName = "win_ade_core.exe"
$X86DLL = Join-Path $PSScriptRoot "Debug\$DllName"
$X86CORE = Join-Path $PSScriptRoot "Debug\$CoreName"
$X64DLL = Join-Path $PSScriptRoot "x64\Debug\$DllName"
$X64CORE = Join-Path $PSScriptRoot "x64\Debug\$CoreName"
$uade_conf = Join-Path $PSScriptRoot "..\uade.conf"
$eagle_conf = Join-Path $PSScriptRoot "..\eagleplayer.conf"
$uaerc = Join-Path $PSScriptRoot "..\uaerc"
$score = Join-Path $PSScriptRoot "..\amigasrc\score\score"
$players = Join-Path $PSScriptRoot "..\players\*"
$database = Join-Path $PSScriptRoot "database\*"

if (-not (Test-Path $X86DLL)) {throw "x86 DLL not found, Please build Debug | x86 first"}
$OutDir = Join-Path $PSScriptRoot "dist"
$ZipPath = Join-Path $OutDir "$ComponentName.zip"
$Fb2kPath = Join-Path $OutDir ("{0}_dbg.fb2k-component" -f $ComponentName)
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$Stage = Join-Path $OutDir "stage"
try {
     New-Item -ItemType Directory -Path (Join-Path $Stage "x64") -Force | Out-Null
	 New-Item -ItemType Directory -Path (Join-Path $Stage "uade") -Force | Out-Null
	 New-Item -ItemType Directory -Path (Join-Path $Stage "uade\players") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Stage "uade\database") -Force | Out-Null
	 Copy-Item $X64DLL (Join-Path $Stage "x64\$DllName") -Force
	 Copy-Item $X64CORE (Join-Path $Stage "x64\$CoreName") -Force
	 Copy-Item $X86Dll $Stage -Force
	 Copy-Item $X86CORE $Stage -Force
	 Copy-Item $uade_conf (Join-Path $Stage "uade\uade.conf") -Force
	 Copy-Item $eagle_conf (Join-Path $Stage "uade\eagleplayer.conf") -Force
	 Copy-Item $uaerc (Join-Path $Stage "uade\uaerc") -Force
	 Copy-Item $score (Join-Path $Stage "uade\score") -Force
	 Copy-Item $players (Join-Path $Stage "uade\players") -Recurse -Force
	 Copy-Item $database (Join-Path $Stage "uade\database") -Recurse -Force
	 if (Test-Path $Fb2kPath) { Remove-Item $Fb2kPath -Force }
	 Compress-Archive -Path (Join-Path $Stage "*") -DestinationPath $ZipPath -Force
     Rename-Item -Path $ZipPath -NewName ([IO.Path]::GetFileName($Fb2kPath))
	 Write-Host "Packed fb2k component in: $Fb2kPath"
} 
finally {
	 if (Test-Path $Stage) {Remove-Item $Stage -Recurse -Force}
}