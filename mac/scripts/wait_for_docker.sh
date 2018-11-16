#!/usr/bin/env sh

set -e
set -o pipefail

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

while ! { docker ps | grep dox-compose_$1_1 ; } ; do
    printf '.'
    sleep 1
done

echo $1 service started
