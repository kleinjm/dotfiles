#!/bin/sh

set -e
set -o pipefail

# copy all files in the diff and delete any remotely deleted files
rsync -avh jamesmkl@jamesmklein.com:/home1/jamesmkl/Music ~/ --delete

# copy over the library file in order to update playlists
scp jamesmkl@jamesmklein.com:"/home1/jamesmkl/Music/iTunes/iTunes\\
Library.itl" ~/Music/iTunes/iTunes\ Library.itl
