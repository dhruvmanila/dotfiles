#!/usr/bin/env bash

set -x

# Place holder for status left/right
place_holder="\#{prefix_highlight}"

main() {
  # Color configuration
  local -r prefix_fg="black"
  local -r prefix_bg="red"
  local -r copy_fg=$prefix_fg
  local -r copy_bg="blue"
  local -r sync_fg=$prefix_fg
  local -r sync_bg="yellow"
  local -r empty_fg="default"
  local -r empty_bg="default"

  # Separator configuration
  local -r prefix_sep=""
  local -r left_sep_bg="#a9dc76"  # bg_green
  # local -r right_sep_fg="#49464e"  # bg4

  # Combining colors and separator
  local -r prefix_color="#[fg=${prefix_fg}]#[bg=${prefix_bg}]"
  local -r copy_color="#[fg=${copy_fg}]#[bg=${copy_bg}]"
  local -r sync_color="#[fg=${sync_fg}]#[bg=${sync_bg}]"
  local -r empty_color="#[fg=${empty_fg}]#[bg=${empty_bg}]"
  local -r prefix_left_sep_color="#[fg=${prefix_bg}]#[bg=${left_sep_bg}]${prefix_sep}"
  local -r copy_left_sep_color="#[fg=${copy_bg}]#[bg=${left_sep_bg}]${prefix_sep}"
  local -r sync_left_sep_color="#[fg=${sync_bg}]#[bg=${left_sep_bg}]${prefix_sep}"
  # local -r prefix_right_sep_color="#[fg=${right_sep_fg}]#[bg=${prefix_bg}]${prefix_sep}"
  # local -r copy_right_sep_color="#[fg=${right_sep_fg}]#[bg=${copy_bg}]${prefix_sep}"
  # local -r sync_right_sep_color="#[fg=${right_sep_fg}]#[bg=${sync_bg}]${prefix_sep}"

  # Prompt strings
  local -r copy_prompt="COPY"
  local -r prefix_prompt="PREFIX"
  local -r sync_prompt="SYNC"
  local -r empty_prompt=""

  # Mode strings
  local -r prefix_mode="${prefix_left_sep_color}${prefix_color} ${prefix_prompt} "
  local -r copy_mode="${copy_left_sep_color}${copy_color} ${copy_prompt} "
  local -r sync_mode="${sync_left_sep_color}${sync_color} ${sync_prompt} "
  local -r empty_mode="${empty_color}${empty_prompt}"

  # Setting the highlight string
  local -r fallback="#{?pane_in_mode,${copy_mode},#{?synchronize-panes,${sync_mode},${empty_mode}}}"
  local -r highlight="#{?client_prefix,${prefix_mode},${fallback}}#[default]"

  # Setting the left status
  local -r status_left_value="$(tmux show-option -gqv "status-left")"
  tmux set-option -gq "status-left" "${status_left_value/$place_holder/$highlight}"

  # Setting the right status
  local -r status_right_value="$(tmux show-option -gqv "status-right")"
  tmux set-option -gq "status-right" "${status_right_value/$place_holder/$highlight}"
}

main
