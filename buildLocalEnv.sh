#!/bin/bash
#
# Run this script local to your `src` code and `requirements.txt` to bundle up a zipped
# python environment, BUILT FOR THE ARCHITECTURE YOU RAN THIS ON
#
set -x
TAG=$(date +%Y%j-%s)
BUILD_DIR=build-$TAG

# Remove current asset
rm lambda.zip

# Create a new local build directory
mkdir -p $BUILD_DIR

# Copy source code into build dir
cp src/* $BUILD_DIR

# Just in case...
touch $BUILD_DIR/__init__.py

# Install dependencies
pip install -r requirements.txt --no-deps -t $BUILD_DIR/

# Compress all source code and deps. Puts them all top level in a zip
# so that you can just reference your `src` code directly as if you are 
# working from there AKA
# src/lambda_handler.py
# Tell your handler is just `lambda_handler.handle`
# NOTE-If you don't zip from within the folder, lambda won't find the handler 
cd $BUILD_DIR
zip -r9 -D ../lambda.zip *