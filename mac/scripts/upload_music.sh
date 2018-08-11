#!/bin/sh

set -e
set -o pipefail

# copy all files in the diff and delete any locally deleted files
rsync -avh ~/Music/ jamesmkl@jamesmklein.com:/home1/jamesmkl/Music --delete

# copy over the library file in order to update playlists
scp ~/Music/iTunes/iTunes\ Library.itl jamesmkl@jamesmklein.com:"/home1/jamesmkl/Music/iTunes/iTunes\\ Library.itl"
