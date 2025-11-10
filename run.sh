#!/bin/bash

# Build the app if not already built or if source files changed
if [ ! -f ".build/release/SleepTimer" ] || [ Sources -nt .build/release/SleepTimer ]; then
    echo "Building Sleep Timer..."
    swift build -c release
    if [ $? -ne 0 ]; then
        echo "Build failed!"
        exit 1
    fi
fi

# Run the application
echo "Starting Sleep Timer..."
.build/release/SleepTimer

