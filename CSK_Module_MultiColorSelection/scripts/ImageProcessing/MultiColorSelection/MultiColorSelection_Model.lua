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
  self.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  self.parameters.registeredEvent = '' -- Event to register to get images to process
  self.parameters.processingFile = 'CSK_MultiColorSelection_Processing' -- Script to use for processing in thread

  self.parameters.showImageChannel = 'Value' -- Image to show in UI viewer (Hue, Saturation, Value)
  self.parameters.showAOI = false -- Show area of interest within image in UI viewer
  self.parameters.showImage = true -- Show image in UI viewer
  self.parameters.maxImageQueueSize = 5 -- Max size of queue. If bigger, images will not be processed

  -- Type of result output
  self.parameters.resultOutput = 'TOTAL+SUBRESULTS' -- 'TOTAL', 'TOTAL+SUBRESULTS', 'TOTAL+SUBVALUES'

  self.parameters.preFilterAOIActive = false -- Prefilter area of interest active
  self.parameters.preFilterAOIChannel = 'Saturation' -- Image channel to use for prefilter AOI
  self.parameters.preFilterAOIMin = 60 -- Min value to consider as AOI
  self.parameters.preFilterAOIMax = 255 -- Max value to consider as AOI

  self.parameters.preFilterAONIActive = false -- Prefilter area of NON interest active
  self.parameters.preFilterAONIChannel = 'Value' -- Image channel to use for prefilter AONI
  self.parameters.preFilterAONIMin = 0 -- Min value to consider as AONI
  self.parameters.preFilterAONIMax = 30 -- Max value to consider as AONI

  self.parameters.colorObjects = {} -- table to hold object configuration

  for i = 1, 12 do
    local obj = {}

    obj.objectName = 'Object' .. tostring(i) -- name of the object
    obj.colorActive = false  -- is this object active
    obj.colorMode = 'Color' -- 1 = Color, 2 = Grayvalue
    obj.colorValue = 1 -- color-value of the object
    obj.regionColor = 1 -- color of the ROI in result image
    obj.colorTolerance = 0 -- tolerance of the object
    obj.minBlobSize = 100 -- minimum blob size
    obj.maxBlobSize = 10000 -- maximum blob size
    obj.pixelRefactorActive = false -- Refactor px/mm active
    obj.pixelRefactorUnit = 'px' -- 'px/mm' or 'px'
    obj.pixelRefactor = 1.0 -- Refactor px/mm
    obj.pixelRefactorUseable = obj.pixelRefactor*obj.pixelRefactor -- calculated pixel refactor
    obj.minGood = 1 -- minimum accepted amount of found objects
    obj.maxGood = 1 -- maximum accepted amount of found objects

    obj.type_ROI = 'Rectangle' -- type of ROI, 'Rectangle' / 'Circle'
    obj.centerX_ROI = 100.0 -- xPos of ROI
    obj.centerY_ROI = 100.0 -- yPos of ROI
    obj.radius_ROI = 100.0 -- radius of ROI if circle
    obj.width_ROI = 100.0 -- width of ROI
    obj.height_ROI = 100.0 -- height of ROI
    obj.center_ROI = Point.create(obj.centerX_ROI, obj.centerY_ROI) -- centerPoint of ROI
    obj.ROI = Shape.createRectangle(obj.center_ROI, obj.width_ROI, obj.height_ROI) -- ROI itself
    obj.roiActive = false -- is ROI active

    obj.type_maskingROI = 'Rectangle' -- type of masks, 'Rectangle' / 'Circle'
    obj.maskingROIActive = false -- is maskingROI active

    obj.maskingROIs = {} -- table of masks to not consider within image

    local mask = {} -- single mask
    local maskCP = Point.create(100.0, 100-0) -- centerPoint of maskingROI
    mask.mask = Shape.createRectangle(maskCP, 100.0, 100.0) -- mask itself

    table.insert(obj.maskingROIs, mask)

    obj.maskingROIComposite = Shape.Composite.create() -- Composite of all masks together
    Shape.Composite.addShape(obj.maskingROIComposite, mask.mask)

    table.insert(self.parameters.colorObjects, obj)

  end

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