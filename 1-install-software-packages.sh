#!/usr/bin/env bash

# Required packages.
# Borrowed from Dockerfile.
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
                            libsodium-dev \
                            openjdk-11-jdk-headless \
                            ant \
                            git \
                            libbz2-dev \
                            liblzma-dev \
                            libcairo2-dev \
                            libcurl4-openssl-dev \
                            libfontconfig1-dev \
                            libpcre3-dev \
                            libssl-dev \
                            libxml2 \
                            libxml2-dev \
                            openjdk-11-jdk-headless \
                            pandoc \
                            zlib1g-dev
sudo apt-get clean

# Add Rig to easily switch between version
sudo curl -L https://rig.r-pkg.org/deb/rig.gpg -o /etc/apt/trusted.gpg.d/rig.gpg
sudo sh -c 'echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list'
sudo apt update
sudo apt install r-rig

# Install version 4.0.5
rig add 4.0.5
rig default 4.0.5

# Confirm we're on R 4.0.5
Rscript -e "R.Version()"

# Confirm java works
java --version

# Check GCC version
gcc --version

