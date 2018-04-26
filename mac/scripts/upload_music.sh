#!/bin/sh

set -e
set -o pipefail

rsync -avh ~/Music/ jamesmkl@jamesmklein.com:/home1/jamesmkl/Music --delete
