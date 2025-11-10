#!/bin/bash

set -e
# swiftlint lint --quiet || true
swift build -c release
./create-app.sh