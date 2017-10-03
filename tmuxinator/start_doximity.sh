#!/bin/bash

# a lot of apps rely on the docker container in doximity so keep it at top
tmuxinator start activities --no-attach
tmuxinator start colleagues --no-attach
tmuxinator start email-delivery --no-attach
tmuxinator start residency --no-attach
tmuxinator start vue-client --no-attach
tmuxinator start dotfiles --no-attach

tmuxinator start doximity
