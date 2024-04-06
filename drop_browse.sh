#!/bin/bash
. activate dropbox
python ~/bin/dropbox_connector.py "$@"
. deactivate
