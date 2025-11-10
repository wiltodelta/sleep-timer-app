#!/bin/bash

set -e
swiftlint lint --quiet
swift build -c release
./create-app.sh