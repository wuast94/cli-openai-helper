#!/bin/zsh

# This ZSH plugin reads the text from the current buffer
# and uses a Python script to complete the text.

create_completion() {
    # Get the text typed until now.
    # Debug output
        echo "Natural language command to process: $BUFFER" >&2
    text=${BUFFER}
    completion=$(echo -n "$text" | $ZSH_CUSTOM/plugins/cli-openai-helper/create_completion.py $CURSOR)
    text_before_cursor=${text:0:$CURSOR}
    text_after_cursor=${text:$CURSOR}
    # Add completion to the current buffer.
    BUFFER=${completion}
    prefix_and_completion="${text_before_cursor}${completion}"
    # Put the cursor at the end of the completion
    CURSOR=${#completion}
}

# Create a new zle widget
zle -N create_completion_widget create_completion

# Bind the create_completion_widget function to Ctrl+F.
bindkey '^F' create_completion_widget
