#!/bin/bash

# Want this as /tmp/nvim-dir-id
NVIM_SOCKET="/tmp/nvim${PWD#$HOME//\//-}-`uuidgen`" 
echo "Starting Neovim server at $NVIM_SOCKET"
# nvim --listen $NVIM_SOCKET
