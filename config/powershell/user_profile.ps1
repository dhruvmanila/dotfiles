# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Aliases
Set-Alias g git
Set-Alias v nvim
Set-Alias vim nvim
Set-Alias p Invoke-FzfProjects

# Activate/deactivate a Python virtual environment.
Set-Alias a activate
Set-Alias d deactivate

# Easier navigation
function ..() { Set-Location .. }
function ...() { Set-Location ..\.. }
function ....() { Set-Location ..\..\.. }
function .....() { Set-Location ..\..\..\.. }
function ......() { Set-Location ..\..\..\..\.. }

# Add terminal icons using nerd-fonts
Import-Module Terminal-Icons

# Readline
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History

# Smart history navigation
Set-PSReadLineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+n -Function HistorySearchForward

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord

# PsFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# https://github.com/dahlbyk/posh-git
Import-Module posh-git

# Prompt
Invoke-Expression (&starship init powershell)

# Completions
pyvenv completion powershell | Out-String | Invoke-Expression

# Windows equivalent of unix `which` command
function which($command) {
  Get-Command -Name $command -All -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Invoke fzf on all the available work project. This uses the fact
# that all projects are git repository and so no need to maintain a
# list of projects separately.
function Invoke-FzfProjects() {
  if (Get-Command -Name fd -ErrorAction SilentlyContinue) {
    fd `
      --type directory `
      --maxdepth 3 `
      --hidden `
      --glob `
      --absolute-path `
      "**.git" `
      "$env:USERPROFILE\workspace"
        | Split-Path
        | Invoke-Fzf
        | Set-Location
    # Activate the Python virtual environment
    activate
  } else {
    Write-Error -Message "command not found: 'fd'"
  }
}

# Activate a Python virtual environment using the `pyvenv` command.
# https://github.com/dhruvmanila/pyvenv
function activate() {
  if (Get-Command -Name pyvenv -ErrorAction SilentlyContinue) {
    $VenvDir = (pyvenv --venv)
    if ($VenvDir) {
      Invoke-Expression -Command "$VenvDir/Scripts/Activate.ps1"
    }
  } else {
    Write-Error -Message "command not found: 'pyvenv'"
  }
}
