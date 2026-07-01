#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_PATH="$DIR/IconExtractor.app"

echo "Building IconExtractor.app..."

# Clean up previous build if exists
rm -rf "$APP_PATH"

# Compile the AppleScript to an App bundle
osacompile -o "$APP_PATH" "$DIR/Scripts/main.applescript"

# Create directories
mkdir -p "$APP_PATH/Contents/Resources/bin"
mkdir -p "$APP_PATH/Contents/Resources/Scripts"

# Copy resources
cp -r "$DIR/bin/decant" "$APP_PATH/Contents/Resources/bin/"
cp "$DIR/Scripts/crop_and_merge.py" "$APP_PATH/Contents/Resources/Scripts/"
cp -r "$DIR/Scripts/svg" "$APP_PATH/Contents/Resources/Scripts/"

# Ensure decant is executable
chmod +x "$APP_PATH/Contents/Resources/bin/decant/decant"

echo "Build complete! IconExtractor.app has been created in this folder."
