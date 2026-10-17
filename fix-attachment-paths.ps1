$root = (Get-Location).Path
Get-ChildItem -Recurse -Filter *.md -File | ForEach-Object {
  $rel = $_.DirectoryName.Substring($root.Length).TrimStart('\')
  if (-not $rel) { return }
  $depth = ($rel -split '\\').Count
  $prefix = '../' * $depth
  $c = [IO.File]::ReadAllText($_.FullName)
  $n = $c -replace '\((?:\./)?attachments/', "($prefix`attachments/"
  if ($n -ne $c) {
    [IO.File]::WriteAllText($_.FullName, $n)
    Write-Host "updated:" $_.Name
  }
}