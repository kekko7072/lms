#!/bin/bash

# Set the release version, output file, signature, and length
release_version="1.0"
output="https://your_domain/your_path/your_app.dmg"
signature="your_ed_signature"
length="123456789"

# Define the replacement text
replacement_text="<item>\n<title>Version $release_version</title>\n<sparkle:releaseNotesLink>\nhttps://your_domain/your_path/release_notes.html\n</sparkle:releaseNotesLink>\n<pubDate>Mon, 6 Mar 2023 13:00:00 +0800</pubDate>\n<enclosure url=\"$output\"\nsparkle:edSignature=\"$signature\"\nlength=\"$length\"\nsparkle:version=\"$release_version\"\nsparkle:os=\"macos\"\ntype=\"application/octet-stream\" />\n</item>"

# Use sed to replace the text between the <!--macOS_start--> and <!--macOS_end--> comments with the replacement text
sed -i '' '/<!--macOS_start-->/,/<\!--macOS_end-->/c\'"$replacement_text"'' dist/appcast.xml
