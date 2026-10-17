# fix-attachment-paths.ps1
# Run from vault root (same folder as attachments/)

$ErrorActionPreference = "Stop"
$root = (Get-Location).Path

Write-Host "Vault: $root"
$updated = 0

Get-ChildItem -Path $root -Recurse -Filter *.md -File | ForEach-Object {
    $fullPath = $_.FullName
    $relDir = $_.DirectoryName.Substring($root.Length).TrimStart('\', '/')

    if ([string]::IsNullOrWhiteSpace($relDir)) {
        $depth = 0
    } else {
        $depth = @($relDir -split '[\\/]' | Where-Object { $_ -ne '' }).Count
    }

    $content = [System.IO.File]::ReadAllText($fullPath)
    $original = $content

    # Fix previous BEL corruption: \x07 + "ttachments" -> "attachments"
    $content = $content.Replace([string][char]7 + "ttachments/", "attachments/")

    if ($depth -eq 0) {
        if ($content -ne $original) {
            [System.IO.File]::WriteAllText($fullPath, $content, [System.Text.UTF8Encoding]::new($false))
            Write-Host "[fixed-garbled]" $_.Name
            $updated++
        }
        return
    }

    $prefix = "../" * $depth
    $replacement = "(" + $prefix + "attachments/"

    $content = $content.Replace("(./attachments/", $replacement)
    $content = $content.Replace("(attachments/", $replacement)

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($fullPath, $content, [System.Text.UTF8Encoding]::new($false))
        Write-Host "[updated] depth=$depth" $_.FullName.Substring($root.Length + 1)
        $updated++
    }
}

Write-Host "Done. Updated $updated file(s)."