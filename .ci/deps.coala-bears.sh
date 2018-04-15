#!/bin/bash

set -x
set -e
pwd
# making coala cache the dependencies downloaded upon first run
echo '' > /tmp/dummy
which coala
coala --ci -V --bears CheckstyleBear,ScalaLintBear --files /tmp/dummy --no-config --bear-dirs bears

rm /tmp/dummy
