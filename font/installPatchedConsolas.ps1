$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace(0x14)
Invoke-WebRequest -Uri 'https://github.com/nicolalamacchia/powerline-consolas/blob/master/consola.ttf?raw=true' -OutFile 'consola.ttf'
$objFolder.CopyHere("$(Resolve-Path .)\consola.ttf")
