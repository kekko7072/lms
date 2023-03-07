#!/bin/bash

echo 

# Ask user to insert the version number matching in pubspec.yaml
read -p "Insert number of release from pubspec.yaml: " release_version

# Ask user to choose between macOS or Windows
echo "Possible platform to release:"
echo "+ 0: macOS"
echo "+ 1: Windows"
# Prompt the user to choose between macOS or Windows
read -p "Select platform: " release_choice

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

    file_path="dist/appcast.xml"
    replacement="<item>\n<title>Version $release_version</title>\n<sparkle:releaseNotesLink>\nhttps://your_domain/your_path/release_notes.html\n</sparkle:releaseNotesLink>\n<pubDate>Mon, 6 Mar 2023 13:00:00 +0800</pubDate>\n<enclosure url=\"$output\"\nsparkle:edSignature=\"$signature\"\nlength=\"$length\"\nsparkle:version=\"$release_version\"\nsparkle:os=\"macos\"\ntype=\"application/octet-stream\" />\n</item>"
    
    replacement="<item>\n<title>Version $release_version</title>\n<sparkle:releaseNotesLink>\nhttps://your_domain/your_path/release_notes.html\n</sparkle:releaseNotesLink>\n<pubDate>Mon, 6 Mar 2023 13:00:00 +0800</pubDate>\n<enclosure url=\"$url\"\nsparkle:edSignature=\"$signature\"\nlength=\"$length\"\nsparkle:version=\"$release_version\"\nsparkle:os=\"macos\"\ntype=\"application/octet-stream\" />\n</item>"

    # Use sed to replace the text between the #macOS div tags
    sed -i '' 's|\(<!--macOS_start-->\).*\(<!--macOS_end-->\)|\1'"$replacement"'\2|g' "$file_path"

elif [ "$release_choice" == "1" ]; then

    # Print what you will run
    echo "flutter_distributor release --name dev --jobs release-windows"

    # Run the command and store the output in the variable
    url=$(flutter_distributor release --name dev --jobs release-windows | grep -o "dist/.*\.zip")

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
else
    echo "Invalid release choice. Please choose between 'macOS' or 'Windows'."
    exit 1
fi

# Deploy to Firebase
#firebase deploy