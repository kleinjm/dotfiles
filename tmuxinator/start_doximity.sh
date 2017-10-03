#!/bin/bash

# a lot of apps rely on the docker container in doximity so keep it at top
tmuxinator start doximity

tmuxinator start activities
tmuxinator start colleagues
tmuxinator start email-delivery
tmuxinator start residency
tmuxinator start vue-client

tmuxinator start dotfiles

tmux attach -t doximity
