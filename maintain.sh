#!/bin/bash

set -e
swiftlint lint --fix
swift test
swift build -c release
./create-app.sh