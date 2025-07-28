# Changelog
All notable changes to this project will be documented in this file.

## Release 3.1.0

### New features
- Check if persistent data to load provides all relevant parameters. Otherwise add default values

### Improvements
- Better instance handling regarding FlowConfig

### Bugfix
- Legacy bindings of ValueDisplay elements within UI did not work if deployed with VS Code AppSpace SDK
- UI differs if deployed via Appstudio or VS Code AppSpace SDK
- Fullscreen icon of iFrame was visible

## Release 3.0.0

### New features
- Supports FlowConfig feature to set images to process / provide results
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- check if instance exists if selected
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Changed log level of some messages from 'info' to 'fine'
- Added UI icon and browser tab information

### Bugfix
- Never deregistered from events
- Error if module is not active but 'getInstancesAmount' was called
- processInstanceNUM did not work after deregistering from event to process images
- Reset of masks switched between circle and rectangle

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