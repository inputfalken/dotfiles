git clone https://github.com/powerline/fonts
Push-Location fonts
.\install.ps1 'Source Code Pro*'
Pop-Location
# Clean everything in current directory
git clean -ffxd
