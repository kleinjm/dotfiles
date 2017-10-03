#!/bin/bash

# start tmux
tmux

# a lot of apps rely on the docker container in doximity so keep it at top
tmuxinator start doximity
tmux detach

tmuxinator start activities
tmux detach
tmuxinator start colleagues
tmux detach
tmuxinator start email-delivery
tmux detach
tmuxinator start residency
tmux detach
tmuxinator start vue-client
tmux detach

tmuxinator start dotfiles
tmux detach

tmux attach -t doximity
