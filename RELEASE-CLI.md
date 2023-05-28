# List of command to create a release

## macOS
    1. Run: flutter_distributor release --name dev --jobs release-macos 
    2. Copy url : Successfully packaged URL_TO_COPY
    3. Paste url and run: flutter pub run auto_updater:sign_update URL_TO_COPY
    4. Copy sparkle:edSignature="ID_TO_COPY" length="LENGTH_TO_COPY"
    5. Paste ID_TO_COPY and LENGTH_TO_COPY into appcast.xml
    6. Change sparkle:version="VERSION_TO_CHANGE" to corretct new verion
    7. Change <enclosure url="VERSION_TO_CHANGE" to corretct new verion
    8. Run: firebase deploy

## Windows TODO
    1. Run: flutter_distributor release --name dev --jobs release-windows 
    2. Copy url : Successfully packaged URL_TO_COPY
    3. Paste url and run: flutter pub run auto_updater:sign_update URL_TO_COPY
    4. Copy sparkle:edSignature="ID_TO_COPY"
    5. Paste ID_TO_COPY into appcast.xml
    6. Change sparkle:version="VERSION_TO_CHANGE+BUILD_NUMBER" to corretct new verion
    7. Change <enclosure url="VERSION_TO_CHANGE" to corretct new verion
    8. Run: firebase deploy