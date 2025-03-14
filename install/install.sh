#!/bin/bash

# Get OS
OS=$(uname -s)

# GitHub repository details
REPO="https://api.github.com/repos/Tosty159/testing-github-actions/releases/latest"
ARCHIVE_URL=""

# Get the latest release
LATEST_RELEASE=$(curl -s $REPO)
if [[ $OS == "Linux" ]]; then
    ARCHIVE_URL=$(echo $LATEST_RELEASE | jq -r '.assets [] | select(.name | test("code-linux.tar.gz")) | .browser_download_url')
elif [[ $OS == "Darwin" ]]; then
    ARCHIVE_URL=$(echo $LATEST_RELEASE | jq -r '.assets[] | select(.name | test("code-linux.tar.gz")) | .browser_download_url')
fi

# Check if URL was found
if [ -z "$ARCHIVE_URL" ]; then
    echo "No compatible archive found for: $OS"
    exit 1
fi

# Download the archive
echo "Downloading the release..."
curl -L $ARCHIVE_URL -o /tmp/code.tar.gz

# Unpack the archive
echo "Extracting the release..."
tar -xzvf /tmp/code.tar.gz -C /tmp

# Variables for paths
EXECUTABLE="/tmp/run_c"
WRAPPER_SCRIPT="/temp/run_c.sh"
INSTALL_DIR="usr/local/bin/run_c"

# Make directory
sudo mkdir -p $INSTALL_DIR

# Install executable and wrapper script
echo "Installing executable..."
cp "$EXECUTABLE" "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/run_c"

echo "Installing wrapper script..."
cp "$WRAPPER_SCRIPT" "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/run_c.sh"

# Clean up
rm -rf /tmp/code*

echo "Installation complete. You can run 'code' from your terminal!"