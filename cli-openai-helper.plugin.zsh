#!/bin/zsh

# This ZSH plugin processes a natural language command starting with a hashtag
# and uses a Python script to generate the actual shell command to be executed.

create_completion() {
    # Check if the buffer starts with a hashtag.
    if [[ $BUFFER =~ '^# ' ]]; then
        # Debug output
        echo "Buffer before processing: $BUFFER" >&2

        # Remove the hashtag from the command.
        local nl_command=${BUFFER:2}

        # Debug output
        echo "Natural language command to process: $nl_command" >&2

        # Call the Python script with the natural language command.
        local completion=$(echo -n "$nl_command" | $ZSH_CUSTOM/plugins/cli-openai-helper/create_completion.py $CURSOR)

        # Debug output
        echo "Generated command from Python script: $completion" >&2

        # Replace the buffer with the generated command.
        BUFFER=$completion

        # Debug output
        echo "Buffer after processing: $BUFFER" >&2

        # Set the cursor position at the end of the buffer.
        CURSOR=$#BUFFER
    fi
}


# Assuming create_completion is a function defined elsewhere in your script

function zsh_accept_line() {
    # Call your custom completion function
    create_completion
    # Call the original accept-line widget
    zle .accept-line
}

# Create a ZLE widget that calls zsh_accept_line
zle -N accept-line zsh_accept_line

# Bind the Enter key to your custom widget
bindkey '^M' accept-line
