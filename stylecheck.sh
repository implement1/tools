#!/bin/bash

ROOT=$NSONE_DEV_ROOT
if [ -z "$ROOT" ]; then
  echo "WARNING: NSONE_DEV_ROOT environment variable is not set"
  ROOT=.
fi
pushd $ROOT >/dev/null

# i ignore E202 (whitespace before '}') because it is better to do this:
#
# foo = {
#     'bar': 'baz',
#     'bat': 'bah',
#     'boo': 'hoo'
#   }
#
# than to do this:
#
# foo = {'bar': 'baz',
#        'bat': 'bah',
#        'boo': 'hoo'}
#

REPOS="nsone-common nsoned outboundd apid status lbd mond notifyd xfrd testing pulse-scheduler pulse-rdetector pulse-beacon pulse-agg"
for r in $REPOS
do
    echo "==== $r ===="
    out1=$(flake8 --ignore=E202,E123 $r)
    if [[ -z "$out1" ]]; then
        echo "CLEAN"
    else
        if [[ ! -z "$out1" ]]; then
            echo "$out1"
        fi
    fi
done

popd >/dev/null
