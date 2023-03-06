#!/bin/bash

# Ask user to choose between macOS or Windows
echo "Possible platform to release:"
echo "+ 0: macOS"
echo "+ 1: Windows"
# Prompt the user to choose between macOS or Windows
read -p "Insert number of platform: " release_choice

if [ "$release_choice" == "0" ]; then

    # Print what you will run
    echo "flutter_distributor release --name dev --jobs release-macos"

    # Run the command and store the output in the variable
    url=$(flutter_distributor release --name dev --jobs release-macos | grep -o "dist/.*\.zip")

    # Print the value of the variable
    echo "BUILD PATH: $url"

    # Sign code
    echo "flutter pub run auto_updater:sign_update $url"
    output=$(flutter pub run auto_updater:sign_update "$url")
    echo "$output"

    # Get variables of signed and length
    signature=$(echo "$output" | grep -o 'sparkle:edSignature="[a-zA-Z0-9+/]*=="' | awk -F'"' '{print $2}')
    length=$(echo "$output" | grep -o 'length="[0-9]*"' | awk -F'"' '{print $2}')

    echo "Signature: $signature"
    echo "Length: $length"

    # Update appcast.xml
    sed -i '' "s/sparkle:edSignature=\"[^\"]*\"/sparkle:edSignature=\"$signature\"/" appcast.xml
    sed -i '' "s/sparkle:length=\"[0-9]*\"/sparkle:length=\"$length\"/" appcast.xml
    sed -i '' "s/url=\".*\.zip\"/url=\"$url\"/" appcast.xml

elif [ "$release_choice" == "1" ]; then
    flutter_distributor release --name dev --jobs release-windows
else
    echo "Invalid release choice. Please choose between 'macOS' or 'Windows'."
    exit 1
fi

# Deploy to Firebase
firebase deploy