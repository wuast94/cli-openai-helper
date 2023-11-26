#!/bin/zsh

# This ZSH plugin processes a natural language command starting with a hashtag
# and uses a Python script to generate the actual shell command to be executed.

create_completion() {
    # Check if the buffer starts with a hashtag.
    if [[ $BUFFER =~ '^# ' ]]; then
        # Remove the hashtag from the command.
        local nl_command=${BUFFER:2}
        # Call the Python script with the natural language command.
        local completion=$(echo -n "$nl_command" | $ZSH_CUSTOM/plugins/zsh_codex/create_completion.py $CURSOR)
        # Replace the buffer with the generated command.
        BUFFER=$completion
        # Set the cursor position at the end of the buffer.
        CURSOR=$#BUFFER
    fi
}

# Bind the create_completion function to the accept-line widget,
# which is invoked when the user presses Enter.
zle -N create_completion_widget create_completion
bindkey '^M' create_completion_widget  # '^M' is the control character for Enter (return)

# This function overrides the accept-line widget.
# It first processes the buffer through create_completion, then accepts the line.
function zsh_accept_line() {
    create_completion
    zle .accept-line
}

# Replace the default accept-line with our custom function.
zle -N accept-line zsh_accept_line
