# Helper functions to log to stdout with colors and indicators.

header() {
  bold "==> $1"
}

error() {
  red_bold "[✗] $1"
}

warning() {
  yellow_bold "[!] $1"
}
