# Changelog
All notable changes to this project will be documented in this file.

## Release 2.0.0

### Improvements
- Renamed abbreviations (Roi-ROI, Id-ID)
- Using recursive helper functions to convert Container <-> Lua table

## Release 1.4.0

### Improvements
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

### Bugfix
- Some Enum references were missed

## Release 1.3.0

### Improvements
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME, as this did not work with PersistentData module in merged apps.

## Release 1.2.0

### New features
- Making use of dynamic viewerIDs -> only one single viewer for all instances

### Improvements
- Naming of UI elements and adding some mouse over info texts
- App name added to log messages
- Added ENUM
- Minor edits, docu, added log messages

### Bugfix
- "Reset instance" UI button was also binded to "addInstance"
- Parameter of "OnUserLevelServiceActive" was of type string instead of bool
- UI events notified after pageLoad after 300ms instead of 100ms to not miss

## Release 1.1.0

### New features
- Optionally hide content related to CSK_UserManagement

### Improvements
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Moved asset content into module folder
- Renamed event "OnNewParametersName" to "OnNewParameterName" (consistent to other modules)
- Minor code edits / docu updates

## Release 1.0.0
- Initial commit