$root = (Get-Location).Path
Get-ChildItem -Recurse -Filter *.md -File | ForEach-Object {
  $c = [System.IO.File]::ReadAllText($_.FullName)
  # 去掉 BEL 字符（\u0007），把  ttachments 修回 attachments
  $n = $c -replace '\u0007ttachments/', 'attachments/'
  $n = $n -replace '\x07ttachments/', 'attachments/'
  if ($n -ne $c) {
    [System.IO.File]::WriteAllText($_.FullName, $n, [System.Text.UTF8Encoding]::new($false))
    Write-Host "已修复:" $_.FullName.Substring($root.Length + 1)
  }
}
Write-Host "修复完成"