#!/usr/bin/env python3

from openai import OpenAI

import sys
import os
import configparser

# Get config dir from environment or default to ~/.config
CONFIG_DIR = os.getenv('XDG_CONFIG_HOME', os.path.expanduser('~/.config'))
API_KEYS_LOCATION = os.path.join(CONFIG_DIR, 'openaiapirc')

# Read the secret_key from the ini file ~/.config/openaiapirc
# The format is:
# [openai]
# secret_key=<your secret key>
# model=gpt-4-1106-preview  # Optional: Defaults to gpt-4-1106-preview if not provided

def create_template_ini_file():
    """
    If the ini file does not exist create it and add the secret_key and optionally the model
    """
    if not os.path.isfile(API_KEYS_LOCATION):
        with open(API_KEYS_LOCATION, 'w') as f:
            f.write('[openai]\n')
            f.write('secret_key=\n')
            f.write('model=gpt-4-1106-preview\n')

        print('OpenAI API config file created at {}'.format(API_KEYS_LOCATION))
        print('Please edit it and add your secret key')
        print('If you do not yet have a secret key, you need to register for OpenAI API access.')
        sys.exit(1)

def initialize_openai_api():
    """
    Initialize the OpenAI API
    """
    # Check if file at API_KEYS_LOCATION exists
    create_template_ini_file()
    config = configparser.ConfigParser()
    config.read(API_KEYS_LOCATION)

    client = OpenAI(api_key=config['openai']['secret_key'].strip('"').strip("'"))

    model = config['openai'].get('model', 'gpt-4-1106-preview').strip('"').strip("'")

    return model

model = initialize_openai_api()

cursor_position_char = int(sys.argv[1])

# Read the input prompt from stdin.
buffer = sys.stdin.read()
prompt_prefix = buffer[:cursor_position_char]
prompt_suffix = buffer[cursor_position_char:]
full_command = prompt_prefix + prompt_suffix

# Add additional parameters such as temperature and max_tokens as desired
response = client.completions.create(model=model,
prompt=[
    {"role": "system", "content": "You are a zsh shell expert, please help me complete the following command, you should only output the completed command, no need to include any other explanation."},
    {"role": "user", "content": full_command}
],
temperature=0.5,  # Change this value to adjust randomness
max_tokens=150,   # Change this value to adjust the maximum length of the completion
n=1,              # Number of completions to generate
stop=None,        # Sequence where the API should stop generating further tokens
user="zsh-user")

completed_command = response.choices[0].text.strip()

sys.stdout.write(f"\n{completed_command.replace(prompt_prefix, '', 1)}")