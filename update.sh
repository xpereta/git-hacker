#!/bin/sh

# Discard output to avoid spoilers
exec 3>&1 4>&2 >/dev/null 2>/dev/null

remote="origin"

print_usage() {
  cat <<EOF
Usage: $0 [-u remote]
       $0 -h

Update the game. This will overwrite all local branches under the "game"
and "meta" branch namespaces.

OPTIONS
    -u remote
    	The git remote to update from. Defaults to "$remote".
    -h
    	Show this help message.
EOF
}

[ -z "${*##*--help*}" ] && { print_usage >&3; exit 0; }
while getopts r:h opt; do
  case $opt in
    r)
      remote="$OPTARG"
      ;;
    h)
      print_usage >&3
      exit 0
      ;;
  esac
done

# don't shift args; flags will be passed down to the next invocation

# This script proceeds in multiple passes to make sure that the script
# is up to date.

case ${CTHULHU_UPDATE_PASS:=1} in
  1)
    # update the current branch and fetch the new branches
    # this will pull in any updated version of the script
    git pull --ff-only "$remote" || exit
    ;;
  2)
    # update all local project branches
    git branch --list 'game/*' 'meta/*' |
      while read branch; do
        git branch --track --force "$branch" "$remote/$branch"
      done
    ;;
  *) exit ;;
esac

CTHULHU_UPDATE_PASS=$((CTHULHU_UPDATE_PASS + 1)) exec "$0" "$@" >&3 2>&4
