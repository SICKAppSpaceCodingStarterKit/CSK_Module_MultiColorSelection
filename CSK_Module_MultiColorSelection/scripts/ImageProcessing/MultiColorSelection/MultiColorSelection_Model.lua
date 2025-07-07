---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiColorSelection'

-- Create kind of "class"
local multiColorSelection = {}
multiColorSelection.__index = multiColorSelection

multiColorSelection.styleForUI = 'None' -- Optional parameter to set UI style
multiColorSelection.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiColorSelection.styleForUI = theme
  Script.notifyEvent("MultiColorSelection_OnNewStatusCSKStyle", multiColorSelection.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiColorSelectionInstanceNo int Number of instance
---@return table[] self Instance of multiColorSelection
function multiColorSelection.create(multiColorSelectionInstanceNo)

  local self = {}
  setmetatable(self, multiColorSelection)

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  self.multiColorSelectionInstanceNo = multiColorSelectionInstanceNo
  self.multiColorSelectionInstanceNoString = tostring(self.multiColorSelectionInstanceNo)
  self.helperFuncs = require('ImageProcessing/MultiColorSelection/helper/funcs')

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Is current camera selected via UI (see "setSelectedCam")

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiColorSelection_Parameter' .. self.multiColorSelectionInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters = self.helperFuncs.defaultParameters.getParameters() -- Load default parameters

  local colorObjectsContainer = self.helperFuncs.convertTable2Container(self.parameters.colorObjects)

  -- Parameters to give to the processing script
  self.multiColorSelectionProcessingParams = Container.create()
  self.multiColorSelectionProcessingParams:add('multiColorSelectionInstanceNumber', multiColorSelectionInstanceNo, "INT")
  self.multiColorSelectionProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")

  self.multiColorSelectionProcessingParams:add('preFilterAOIActive', self.parameters.preFilterAOIActive, "BOOL")
  self.multiColorSelectionProcessingParams:add('preFilterAOIChannel', self.parameters.preFilterAOIChannel, "STRING")
  self.multiColorSelectionProcessingParams:add('preFilterAOIMin', self.parameters.preFilterAOIMin, "INT")
  self.multiColorSelectionProcessingParams:add('preFilterAOIMax', self.parameters.preFilterAOIMax, "INT")

  self.multiColorSelectionProcessingParams:add('preFilterAONIActive', self.parameters.preFilterAONIActive, "BOOL")
  self.multiColorSelectionProcessingParams:add('preFilterAONIChannel', self.parameters.preFilterAONIChannel, "STRING")
  self.multiColorSelectionProcessingParams:add('preFilterAONIMin', self.parameters.preFilterAONIMin, "INT")
  self.multiColorSelectionProcessingParams:add('preFilterAONIMax', self.parameters.preFilterAONIMax, "INT")

  self.multiColorSelectionProcessingParams:add('showImageChannel', self.parameters.showImageChannel, "STRING")
  self.multiColorSelectionProcessingParams:add('showAOI', self.parameters.showAOI, "BOOL")

  self.multiColorSelectionProcessingParams:add('maxImageQueueSize', self.parameters.maxImageQueueSize, "INT")

  self.multiColorSelectionProcessingParams:add('showImage', self.parameters.showImage, "BOOL")
  self.multiColorSelectionProcessingParams:add('viewerID', 'multiColorSelectionViewer' .. self.multiColorSelectionInstanceNoString, "STRING")

  self.multiColorSelectionProcessingParams:add('colorObjects', colorObjectsContainer, "OBJECT")

  self.multiColorSelectionProcessingParams:add('resultOutput', self.parameters.resultOutput, "STRING")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiColorSelectionProcessingParams)

  return self
end

return multiColorSelection

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************