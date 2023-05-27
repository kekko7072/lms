# Link Management System
_Make managing your links quick and easy!_

The Link Management System app **makes it **easy**** to **store** and **manage** all of your important **links**. Manage your entire link library with the app’s intuitive organisation system, which allows you to quickly find and open links by description or title.
You can also easily **add new links** to the system, categorize them, and edit their details with just a few clicks.

## Download
### New release v. 1.1.0 [DOWNLOAD](https://github.com/kekko7072/lms/releases/tag/1.1.0)
This has new improvements and it's finally available on the [release note](https://github.com/kekko7072/lms/releases/tag/1.1.0) page.

## Credits
This app was initially developed as an exercise, but quickly became a useful and practical tool for managing everyday links. 
### Simone Procari, Riccardo Rettore and Francesco Vezzani

## Release
Follow specific platform release pipeline and then create a release in GitHub where put the files.
### macOS
Archive the app in Xcode, Windows >Distribute App > Developer ID > Export Notarized App
### Windows
Run 'flutter build windows'. In the folder 'build/windows/runner/Release/', as said in [package instructions](https://pub.dev/packages/sqflite_common_ffi#windows) add the file sqlite3.dll [downlaod](https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll) if it's not already there. Open the file desktop_inno_script.iss with Inno Setup Compiler and Run the script.

## Build
### macOS
Run on Debug or Release Mode.

### Windows
Follow this [video](https://www.youtube.com/watch?v=XvwX-hmYv0E) to build the .exe file. As said in [package instructions](https://pub.dev/packages/sqflite_common_ffi#windows) remember that in <b>release mode</b> you need to add the file sqlite3.dll [downlaod](https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll) in same folder as your executable. Publish the LMS.exe file.

### Linux
Never tested.
