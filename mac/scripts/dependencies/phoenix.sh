#!/bin/sh

set -e
set -o pipefail

echo "Installing Phoenix"

# https://hexdocs.pm/phoenix/installation.html#elixir-1-5-or-later
mix local.hex

# https://hexdocs.pm/phoenix/installation.html#phoenix
mix archive.install hex phx_new 1.4.1
