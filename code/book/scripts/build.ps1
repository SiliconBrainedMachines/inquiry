param(
    [ValidateSet('draft', 'pdf', 'epub', 'all')]
    [string]$Format = 'all',

    [ValidateSet('en', 'es')]
    [string]$Lang = 'en'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$bookRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$buildDir = Join-Path $bookRoot 'build'
$distDir = Join-Path $bookRoot 'dist'
$srcDir = Join-Path $bookRoot (Join-Path 'src' $Lang)
$templateDir = Join-Path $bookRoot 'templates'
$headerPath = Join-Path $templateDir 'pandoc-typst-header.typ'
$mainTypPath = Join-Path $bookRoot "main-$Lang.typ"
$combinedTmpPath = Join-Path $buildDir "combined-$Lang.typ.tmp"
$combinedPath = Join-Path $buildDir "combined-$Lang.typ"
$epubMetaPath = Join-Path $templateDir "epub-metadata-$Lang.yaml"
$epubCssPath = Join-Path $templateDir 'epub.css'

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    throw 'pandoc no encontrado en PATH.'
}

$srcFiles = Get-ChildItem -Path $srcDir -Filter '*.md' |
    Sort-Object Name |
    ForEach-Object { $_.FullName }

if ($srcFiles.Count -eq 0) {
    throw "No se encontraron capitulos Markdown en $srcDir"
}

New-Item -ItemType Directory -Force -Path $buildDir, $distDir | Out-Null

function Invoke-PandocTypstBuild {
    & pandoc @srcFiles -t typst -o $combinedTmpPath
    if ($LASTEXITCODE -ne 0) {
        throw 'pandoc fallo al generar el combinado Typst.'
    }

    $headerText = Get-Content -LiteralPath $headerPath -Raw
    $bodyText = Get-Content -LiteralPath $combinedTmpPath -Raw
    Set-Content -LiteralPath $combinedPath -Value ($headerText + [Environment]::NewLine + $bodyText) -NoNewline
    Remove-Item -LiteralPath $combinedTmpPath -Force
}

function Invoke-TypstCompile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    if (-not (Get-Command typst -ErrorAction SilentlyContinue)) {
        throw 'typst no encontrado en PATH.'
    }

    Invoke-PandocTypstBuild
    & typst compile $mainTypPath $OutputPath
    if ($LASTEXITCODE -ne 0) {
        throw "typst fallo al compilar $OutputPath"
    }
}

Push-Location $bookRoot
try {
    switch ($Format) {
        'draft' {
            $draftOut = Join-Path $distDir "draft-$Lang.pdf"
            Invoke-TypstCompile -OutputPath $draftOut
            Write-Host "Draft generado: $draftOut"
        }
        'pdf' {
            $pdfOut = Join-Path $distDir "philo-sophia-$Lang.pdf"
            Invoke-TypstCompile -OutputPath $pdfOut
            Write-Host "PDF generado: $pdfOut"
        }
        'epub' {
            $epubOut = Join-Path $distDir "philo-sophia-$Lang.epub"
            & pandoc @srcFiles "--metadata-file=$epubMetaPath" "--css=$epubCssPath" --toc --toc-depth=2 --split-level=1 -o $epubOut
            if ($LASTEXITCODE -ne 0) {
                throw 'pandoc fallo al generar el EPUB.'
            }
            Write-Host "EPUB generado: $epubOut"
        }
        'all' {
            $pdfOut = Join-Path $distDir "philo-sophia-$Lang.pdf"
            $epubOut = Join-Path $distDir "philo-sophia-$Lang.epub"

            if (Get-Command typst -ErrorAction SilentlyContinue) {
                Invoke-TypstCompile -OutputPath $pdfOut
                Write-Host "PDF generado: $pdfOut"
            } else {
                Write-Warning 'typst no encontrado; se omite la salida PDF.'
            }

            & pandoc @srcFiles "--metadata-file=$epubMetaPath" "--css=$epubCssPath" --toc --toc-depth=2 --split-level=1 -o $epubOut
            if ($LASTEXITCODE -ne 0) {
                throw 'pandoc fallo al generar el EPUB.'
            }
            Write-Host "EPUB generado: $epubOut"
        }
    }
}
finally {
    Pop-Location
}