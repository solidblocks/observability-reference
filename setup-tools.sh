#!/bin/bash
set -e

brew bundle

# Install or update helm-diff plugin
if ! helm plugin list | grep -q diff; then
    echo "Installing helm-diff plugin..."
    helm plugin install https://github.com/databus23/helm-diff
else
    echo "helm-diff plugin already installed, updating..."
    helm plugin update diff
fi

# Verify the installation
if helm plugin list | grep -q diff; then
    DIFF_VERSION=$(helm plugin list | grep diff | awk '{print $2}')
    echo "✅ helm-diff plugin installed successfully (version: $DIFF_VERSION)"
else
    echo "❌ Failed to install or verify helm-diff plugin"
    exit 1
fi

echo "All tools setup complete!" 