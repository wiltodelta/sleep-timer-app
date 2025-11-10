#!/bin/bash

set -e
swiftlint lint --fix
swift build -c release
./create-app.sh