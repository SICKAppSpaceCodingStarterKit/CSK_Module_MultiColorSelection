---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the multiColorSelection_Model and multiColorSelection_Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiColorSelection'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiColorSelection = Timer.create()
tmrMultiColorSelection:setExpirationTime(300)
tmrMultiColorSelection:setPeriodic(false)

-- Reference to global handle
local multiColorSelection_Model -- Reference to model handle
local multiColorSelection_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local selectedStep = '1' -- Which configuration step is currently selected (1-5)
local helperFuncs = require('ImageProcessing/MultiColorSelection/helper/funcs') -- general jelper functions
local selectedColorObject = 1 -- Which color object is currently selected

local pipetteActive = false -- Pipette mode active to select color image
local roiEditorActive = false -- Setting of ROI is currently active
local maskingROIEditorActive = false -- Setting of Mask is currently active

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiColorSelection.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiColorSelection.OnNewResultNUM", "MultiColorSelection_OnNewResultNUM")
Script.serveEvent("CSK_MultiColorSelection.OnNewValueToForwardNUM", "MultiColorSelection_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiColorSelection.OnNewValueUpdateNUM", "MultiColorSelection_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
Script.serveEvent("CSK_MultiColorSelection.OnNewInstanceList", "MultiColorSelection_OnNewInstanceList")
Script.serveEvent("CSK_MultiColorSelection.OnNewSelectedInstance", "MultiColorSelection_OnNewSelectedInstance")

Script.serveEvent('CSK_MultiColorSelection.OnNewStatusRegisteredEvent', 'MultiColorSelection_OnNewStatusRegisteredEvent')

Script.serveEvent('CSK_MultiColorSelection.OnNewViewerID', 'MultiColorSelection_OnNewViewerID')
Script.serveEvent("CSK_MultiColorSelection.OnNewStatusShowImage", "MultiColorSelection_OnNewStatusShowImage")
Script.serveEvent("CSK_MultiColorSelection.OnNewColorObjectSelection", "MultiColorSelection_OnNewColorObjectSelection")
Script.serveEvent("CSK_MultiColorSelection.OnNewStatusColorActive", "MultiColorSelection_OnNewStatusColorActive")
Script.serveEvent("CSK_MultiColorSelection.OnNewObjectName", "MultiColorSelection_OnNewObjectName")
Script.serveEvent("CSK_MultiColorSelection.OnNewColorValue", "MultiColorSelection_OnNewColorValue")
Script.serveEvent("CSK_MultiColorSelection.OnNewColorMode", "MultiColorSelection_OnNewColorMode")
Script.serveEvent("CSK_MultiColorSelection.OnNewValueTolerance", "MultiColorSelection_OnNewValueTolerance")
Script.serveEvent("CSK_MultiColorSelection.OnNewMinBlobSize", "MultiColorSelection_OnNewMinBlobSize")
Script.serveEvent("CSK_MultiColorSelection.OnNewMaxBlobSize", "MultiColorSelection_OnNewMaxBlobSize")
Script.serveEvent("CSK_MultiColorSelection.OnNewStatusPixelRefactorActive", "MultiColorSelection_OnNewStatusPixelRefactorActive")
Script.serveEvent("CSK_MultiColorSelection.OnNewPixelRefactorUnit", "MultiColorSelection_OnNewPixelRefactorUnit")
Script.serveEvent("CSK_MultiColorSelection.OnNewPixelRefactor", "MultiColorSelection_OnNewPixelRefactor")
Script.serveEvent("CSK_MultiColorSelection.OnNewStatusROIActive", "MultiColorSelection_OnNewStatusROIActive")
Script.serveEvent("CSK_MultiColorSelection.OnNewStatusMaskActive", "MultiColorSelection_OnNewStatusMaskActive")

Script.serveEvent('CSK_MultiColorSelection.OnNewROIType', 'MultiColorSelection_OnNewROIType')
Script.serveEvent('CSK_MultiColorSelection.OnNewMaskingROIType', 'MultiColorSelection_OnNewMaskingROIType')

Script.serveEvent("CSK_MultiColorSelection.OnNewMinGood", "MultiColorSelection_OnNewMinGood")
Script.serveEvent("CSK_MultiColorSelection.OnNewMaxGood", "MultiColorSelection_OnNewMaxGood")

Script.serveEvent("CSK_MultiColorSelection.OnNewSelectedStep", "MultiColorSelection_OnNewSelectedStep")

Script.serveEvent("CSK_MultiColorSelection.OnPreFilterAOIActive", "MultiColorSelection_OnPreFilterAOIActive")
Script.serveEvent("CSK_MultiColorSelection.OnNewPreFilterAOIChannel", "MultiColorSelection_OnNewPreFilterAOIChannel")
Script.serveEvent("CSK_MultiColorSelection.OnPreFilterAOIValues", "MultiColorSelection_OnPreFilterAOIValues")

Script.serveEvent("CSK_MultiColorSelection.OnPreFilterAONIActive", "MultiColorSelection_OnPreFilterAONIActive")
Script.serveEvent("CSK_MultiColorSelection.OnNewPreFilterAONIChannel", "MultiColorSelection_OnNewPreFilterAONIChannel")
Script.serveEvent("CSK_MultiColorSelection.OnPreFilterAONIValues", "MultiColorSelection_OnPreFilterAONIValues")

Script.serveEvent("CSK_MultiColorSelection.OnShowAOI", "MultiColorSelection_OnShowAOI")
Script.serveEvent("CSK_MultiColorSelection.OnNewShowImageChannel", "MultiColorSelection_OnNewShowImageChannel")

Script.serveEvent("CSK_MultiColorSelection.OnROIEditorActive", "MultiColorSelection_OnROIEditorActive")
Script.serveEvent("CSK_MultiColorSelection.OnMaskEditorActive", "MultiColorSelection_OnMaskEditorActive")
Script.serveEvent("CSK_MultiColorSelection.OnPipetteActive", "MultiColorSelection_OnPipetteActive")

Script.serveEvent("CSK_MultiColorSelection.OnNewSizeSmallestBlob", "MultiColorSelection_OnNewSizeSmallestBlob")
Script.serveEvent("CSK_MultiColorSelection.OnNewSizeBiggestBlob", "MultiColorSelection_OnNewSizeBiggestBlob")
Script.serveEvent("CSK_MultiColorSelection.OnNewFoundBlobs", "MultiColorSelection_OnNewFoundBlobs")

Script.serveEvent("CSK_MultiColorSelection.OnNewResultOutput", "MultiColorSelection_OnNewResultOutput")
Script.serveEvent("CSK_MultiColorSelection.OnNewResult", "MultiColorSelection_OnNewResult")
Script.serveEvent("CSK_MultiColorSelection.OnNewTotalResult", "MultiColorSelection_OnNewTotalResult")

Script.serveEvent("CSK_MultiColorSelection.OnNewImageQueue", "MultiColorSelection_OnNewImageQueue")

Script.serveEvent("CSK_MultiColorSelection.OnNewProcessingTime", "MultiColorSelection_OnNewProcessingTime")

---------------------------------------

Script.serveEvent("CSK_MultiColorSelection.OnNewProcessingParameter", "MultiColorSelection_OnNewProcessingParameter")

Script.serveEvent("CSK_MultiColorSelection.OnUserLevelOperatorActive", "MultiColorSelection_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiColorSelection.OnUserLevelMaintenanceActive", "MultiColorSelection_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiColorSelection.OnUserLevelServiceActive", "MultiColorSelection_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiColorSelection.OnUserLevelAdminActive", "MultiColorSelection_OnUserLevelAdminActive")

Script.serveEvent("CSK_MultiColorSelection.OnNewParameterName", "MultiColorSelection_OnNewParameterName")
Script.serveEvent("CSK_MultiColorSelection.OnNewStatusLoadParameterOnReboot", "MultiColorSelection_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiColorSelection.OnPersistentDataModuleAvailable", "MultiColorSelection_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiColorSelection.OnDataLoadedOnReboot", "MultiColorSelection_OnDataLoadedOnReboot")

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiColorSelection_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiColorSelection_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiColorSelection_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiColorSelection_OnUserLevelAdminActive", status)
end

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
  if string.sub(parameter, 1, 4) == 'mask' and parameter ~= 'maskingROIComposite' then
    local maskID = tonumber(string.sub(parameter, #parameter, #parameter))
    multiColorSelection_Instances[instance].parameters.colorObjects[selectedObject]["maskingROIs"][maskID]["mask"] = value
  else
    if parameter == 'maskingROIComposite' then
      multiColorSelection_Instances[instance].parameters.colorObjects[selectedObject][parameter] = value
    else
      multiColorSelection_Instances[instance].parameters.colorObjects[selectedObject][parameter] = value
    end
  end
end

--- Function to get access to the multiColorSelection_Model
---@param handle handle Handle of multiColorSelection_Model object
local function setMultiColorSelection_Model_Handle(handle)
  multiColorSelection_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiColorSelection_Model_Handle = setMultiColorSelection_Model_Handle

--- Function to get access to the multiColorSelection_Instances
---@param handle handle Handle of multiColorSelection_Instances object
local function setMultiColorSelection_Instances_Handle(handle)
  multiColorSelection_Instances = handle
  if multiColorSelection_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiColorSelection_Instances do
    Script.register("CSK_MultiColorSelection.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
    Script.register("CSK_MultiColorSelection.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end
end
funcs.setMultiColorSelection_Instances_Handle = setMultiColorSelection_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiColorSelection_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiColorSelection_OnUserLevelOperatorActive", true)
    Script.notifyEvent("MultiColorSelection_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiColorSelection_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiColorSelection_OnUserLevelAdminActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiColorSelection()

  updateUserLevel()

  Script.notifyEvent("MultiColorSelection_OnNewInstanceList", helperFuncs.createStringListBySize(#multiColorSelection_Instances))
  Script.notifyEvent('MultiColorSelection_OnNewSelectedInstance', selectedInstance)

  Script.notifyEvent('MultiColorSelection_OnNewStatusRegisteredEvent', multiColorSelection_Instances[selectedInstance].parameters.registeredEvent)

  Script.notifyEvent('MultiColorSelection_OnNewViewerID', 'multiColorSelectionViewer' .. tostring(selectedInstance))
  Script.notifyEvent('MultiColorSelection_OnNewStatusShowImage', multiColorSelection_Instances[selectedInstance].parameters.showImage)

  Script.notifyEvent("MultiColorSelection_OnNewSelectedStep", selectedStep)

  Script.notifyEvent("MultiColorSelection_OnPreFilterAOIActive", multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIActive)
  Script.notifyEvent("MultiColorSelection_OnNewPreFilterAOIChannel", multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIChannel)
  Script.notifyEvent("MultiColorSelection_OnPreFilterAOIValues", {multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIMin, multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIMax})

  Script.notifyEvent("MultiColorSelection_OnPreFilterAONIActive", multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIActive)
  Script.notifyEvent("MultiColorSelection_OnNewPreFilterAONIChannel", multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIChannel)
  Script.notifyEvent("MultiColorSelection_OnPreFilterAONIValues", {multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIMin, multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIMax})

  Script.notifyEvent("MultiColorSelection_OnShowAOI", multiColorSelection_Instances[selectedInstance].parameters.showAOI)
  Script.notifyEvent("MultiColorSelection_OnNewShowImageChannel", multiColorSelection_Instances[selectedInstance].parameters.showImageChannel)

  Script.notifyEvent("MultiColorSelection_OnNewColorObjectSelection", selectedColorObject)
  Script.notifyEvent("MultiColorSelection_OnNewStatusColorActive", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorActive)
  Script.notifyEvent("MultiColorSelection_OnNewObjectName", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].objectName)
  Script.notifyEvent("MultiColorSelection_OnNewColorValue", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorValue)
  Script.notifyEvent("MultiColorSelection_OnNewColorMode", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorMode)
  Script.notifyEvent("MultiColorSelection_OnNewValueTolerance", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorTolerance)
  Script.notifyEvent("MultiColorSelection_OnNewMinBlobSize", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].minBlobSize)
  Script.notifyEvent("MultiColorSelection_OnNewMaxBlobSize", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].maxBlobSize)
  Script.notifyEvent("MultiColorSelection_OnNewStatusPixelRefactorActive", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorActive)
  Script.notifyEvent("MultiColorSelection_OnNewPixelRefactorUnit", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorUnit)
  Script.notifyEvent("MultiColorSelection_OnNewPixelRefactor", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactor)
  Script.notifyEvent("MultiColorSelection_OnNewStatusROIActive", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].roiActive)
  Script.notifyEvent("MultiColorSelection_OnNewStatusMaskActive", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].maskingROIActive)

  Script.notifyEvent("MultiColorSelection_OnNewROIType", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].type_ROI)
  Script.notifyEvent('MultiColorSelection_OnNewMaskingROIType', multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].type_maskingROI)

  Script.notifyEvent("MultiColorSelection_OnNewMinGood", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].minGood)
  Script.notifyEvent("MultiColorSelection_OnNewMaxGood", multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].maxGood)

  Script.notifyEvent("MultiColorSelection_OnROIEditorActive", roiEditorActive)
  Script.notifyEvent("MultiColorSelection_OnMaskEditorActive", maskingROIEditorActive)
  Script.notifyEvent("MultiColorSelection_OnPipetteActive", pipetteActive)

  Script.notifyEvent("MultiColorSelection_OnNewSizeSmallestBlob", '-')
  Script.notifyEvent("MultiColorSelection_OnNewSizeBiggestBlob", '-')
  Script.notifyEvent("MultiColorSelection_OnNewFoundBlobs", '-')

  Script.notifyEvent("MultiColorSelection_OnNewImageQueue", '-')
  Script.notifyEvent("MultiColorSelection_OnNewProcessingTime", '-')

  Script.notifyEvent("MultiColorSelection_OnNewResultOutput", multiColorSelection_Instances[selectedInstance].parameters.resultOutput)

  Script.notifyEvent('MultiColorSelection_OnNewParameterName', multiColorSelection_Instances[selectedInstance].parametersName)
  Script.notifyEvent("MultiColorSelection_OnNewStatusLoadParameterOnReboot", multiColorSelection_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiColorSelection_OnPersistentDataModuleAvailable", multiColorSelection_Instances[selectedInstance].persistentModuleAvailable)
end
Timer.register(tmrMultiColorSelection, "OnExpired", handleOnExpiredTmrMultiColorSelection)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiColorSelection:start()
  return ''
end
Script.serveFunction("CSK_MultiColorSelection.pageCalled", pageCalled)

local function setSelectedStep(step)
  selectedStep = step
  _G.logger:info(nameOfModule .. ": New step selected = " .. tostring(step))
  Script.notifyEvent("MultiColorSelection_OnNewSelectedStep", selectedStep)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'selectedStep', selectedStep)
end
Script.serveFunction("CSK_MultiColorSelection.setSelectedStep", setSelectedStep)

local function setInstance(instance)

  roiEditorActive = false
  maskingROIEditorActive = false
  pipetteActive = false
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'chancelEditors', true)

  selectedInstance = instance
  selectedColorObject = 1
  setSelectedStep('5')
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiColorSelection_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'selectedColorObject', selectedColorObject)
  handleOnExpiredTmrMultiColorSelection()
end
Script.serveFunction("CSK_MultiColorSelection.setInstance", setInstance)

local function getInstancesAmount ()
  return #multiColorSelection_Instances
end
Script.serveFunction("CSK_MultiColorSelection.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiColorSelection_Instances, multiColorSelection_Model.create(#multiColorSelection_Instances+1))
  Script.deregister("CSK_MultiColorSelection.OnNewValueToForward" .. tostring(#multiColorSelection_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiColorSelection.OnNewValueToForward" .. tostring(#multiColorSelection_Instances) , handleOnNewValueToForward)

  Script.deregister("CSK_MultiColorSelection.OnNewValueUpdate" .. tostring(#multiColorSelection_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiColorSelection.OnNewValueUpdate" .. tostring(#multiColorSelection_Instances) , handleOnNewValueUpdate)

  handleOnExpiredTmrMultiColorSelection()
end
Script.serveFunction('CSK_MultiColorSelection.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setInstance(1)
  local totalAmount = #multiColorSelection_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiColorSelection_Instances[totalAmount])
    multiColorSelection_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiColorSelection()
end
Script.serveFunction('CSK_MultiColorSelection.resetInstances', resetInstances)

local function setShowImage(status)
  _G.logger:info(nameOfModule .. ": Set show image: " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.showImage = status
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'showImage', status)
end
Script.serveFunction("CSK_MultiColorSelection.setShowImage", setShowImage)

local function setPreFilterAOIActive(status)
  _G.logger:info(nameOfModule .. ": Set prefilter AOI active: " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIActive = status
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAOIActive', status)
end
Script.serveFunction("CSK_MultiColorSelection.setPreFilterAOIActive", setPreFilterAOIActive)

local function setPreFilterAOIChannel(channel)
  _G.logger:info(nameOfModule .. ": Set prefilter AOI channel: " .. tostring(channel))
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIChannel = channel
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAOIChannel', channel)
end
Script.serveFunction("CSK_MultiColorSelection.setPreFilterAOIChannel", setPreFilterAOIChannel)

local function setPreFilterAOIRange(values)
  _G.logger:info(nameOfModule .. ": Set prefilter AOI values: " .. tostring(values[1]) .. " - " .. tostring(values[2]))
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIMin = values[1]
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAOIMax = values[2]
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAOIMin', values[1])
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAOIMax', values[2])
end
Script.serveFunction("CSK_MultiColorSelection.setPreFilterAOIRange", setPreFilterAOIRange)

local function setPreFilterAONIActive(status)
  _G.logger:info(nameOfModule .. ": Set prefilter AONI active: " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIActive = status
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAONIActive', status)
end
Script.serveFunction("CSK_MultiColorSelection.setPreFilterAONIActive", setPreFilterAONIActive)

local function setPreFilterAONIChannel(channel)
  _G.logger:info(nameOfModule .. ": Set prefilter AONI channel: " .. tostring(channel))
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIChannel = channel
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAONIChannel', channel)
end
Script.serveFunction("CSK_MultiColorSelection.setPreFilterAONIChannel", setPreFilterAONIChannel)

local function setPreFilterAONIRange(values)
  _G.logger:info(nameOfModule .. ": Set prefilter AONI values: " .. tostring(values[1]) .. " - " .. tostring(values[2]))
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIMin = values[1]
  multiColorSelection_Instances[selectedInstance].parameters.preFilterAONIMax = values[2]
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAONIMin', values[1])
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'preFilterAONIMax', values[2])
end
Script.serveFunction("CSK_MultiColorSelection.setPreFilterAONIRange", setPreFilterAONIRange)

local function setShowImageChannel(channel)
  _G.logger:info(nameOfModule .. ": Set image channel to show: " .. tostring(channel))
  multiColorSelection_Instances[selectedInstance].parameters.showImageChannel = channel
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'showImageChannel', channel)
end
Script.serveFunction("CSK_MultiColorSelection.setShowImageChannel", setShowImageChannel)

local function setShowAOI(status)
  _G.logger:info(nameOfModule .. ": Set show AOI: " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.showAOI = status
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'showAOI', status)
end
Script.serveFunction("CSK_MultiColorSelection.setShowAOI", setShowAOI)

local function setColorObject(selection)
  _G.logger:info(nameOfModule .. ": Set color object: " .. tostring(selection))
  selectedColorObject = selection

  roiEditorActive = false
  maskingROIEditorActive = false
  pipetteActive = false
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'chancelEditors', true)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'selectedColorObject', selection)

  handleOnExpiredTmrMultiColorSelection()

end
Script.serveFunction("CSK_MultiColorSelection.setColorObject", setColorObject)

local function setColorActive(status)
  _G.logger:info(nameOfModule .. ": Set color active: " .. tostring(status))
  _G.logger:info(nameOfModule .. ": Set 'colorActive' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorActive = status

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'colorActive', status, selectedColorObject)

end
Script.serveFunction("CSK_MultiColorSelection.setColorActive", setColorActive)

local function setObjectName(name)
  _G.logger:info(nameOfModule .. ": Set 'objectName' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(name))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].objectName = name

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'objectName', name, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setObjectName", setObjectName)

local function setColorValue(value)
  _G.logger:info(nameOfModule .. ": Set 'colorValue' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(value))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorValue = value
  local regionColor = helperFuncs.selectRegionColor(value)
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].regionColor = regionColor

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'colorValue', value, selectedColorObject)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'regionColor', regionColor, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setColorValue", setColorValue)

local function setColorMode(mode)
  _G.logger:info(nameOfModule .. ": Set 'colorMode' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(mode))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorMode = mode

  Script.notifyEvent('MultiColorSelection_OnNewColorMode', mode)

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'colorMode', mode, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setColorMode", setColorMode)

local function setColorTolerance(value)
  _G.logger:info(nameOfModule .. ": Set 'colorTolerance' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(value))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].colorTolerance = value

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'colorTolerance', value, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setColorTolerance", setColorTolerance)

local function setMinBlobSize(size)
  _G.logger:info(nameOfModule .. ": Set 'minBlobSize' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(size))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].minBlobSize = size

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'minBlobSize', size, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setMinBlobSize", setMinBlobSize)

local function setMaxBlobSize(size)
  _G.logger:info(nameOfModule .. ": Set 'maxBlobSize' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(size))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].maxBlobSize = size

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'maxBlobSize', size, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setMaxBlobSize", setMaxBlobSize)

local function setPixelRefactorActive(status)
  _G.logger:info(nameOfModule .. ": Set 'pixelRefactorActive' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorActive = status

  Script.notifyEvent("MultiColorSelection_OnNewStatusPixelRefactorActive", status)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'pixelRefactorActive', status, selectedColorObject)

  if status == true then
    multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorUnit = 'mm²'
  else
    multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorUnit = 'px'
  end

  Script.notifyEvent('MultiColorSelection_OnNewPixelRefactorUnit', multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorUnit)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'pixelRefactorUnit', multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorUnit, selectedColorObject)

end
Script.serveFunction("CSK_MultiColorSelection.setPixelRefactorActive", setPixelRefactorActive)

local function setPixelRefactor(value)
  _G.logger:info(nameOfModule .. ": Set 'pixelRefactor' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(value))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactor = value
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].pixelRefactorUseable = value * value

  Script.notifyEvent("MultiColorSelection_OnNewPixelRefactor", value)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'pixelRefactorUseable', value*value, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setPixelRefactor", setPixelRefactor)

local function setROIActive(status)
  _G.logger:info(nameOfModule .. ": Set 'roiActive' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].roiActive = status

  Script.notifyEvent("MultiColorSelection_OnNewStatusROIActive", status)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'roiActive', status, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setROIActive", setROIActive)

local function setROIEditor(status)

  _G.logger:info(nameOfModule .. ": Set ROI editor: " .. tostring(status))
  roiEditorActive = status
  Script.notifyEvent("MultiColorSelection_OnROIEditorActive", status)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'roiEditorActive', status)

end
Script.serveFunction("CSK_MultiColorSelection.setROIEditor", setROIEditor)

local function setROIType(roiType)
  _G.logger:info(nameOfModule .. ": Set ROI type: " .. tostring(roiType))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].type_ROI = roiType
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'setTypeROI', roiType)
end
Script.serveFunction('CSK_MultiColorSelection.setROIType', setROIType)

local function resetROI()
  _G.logger:info(nameOfModule .. ": Reset ROI")
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'resetROI', true)
end
Script.serveFunction("CSK_MultiColorSelection.resetROI", resetROI)

local function addMaskingROI()

  _G.logger:info(nameOfModule .. ": Add mask.")
  local temp = {}
  local tempCp = Point.create(100.0, 100.0)
  temp.mask = Shape.createRectangle(tempCp, 100.0, 100.0, 0.0)
  table.insert(multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject]["maskingROIs"], temp)

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'addMaskingROI', status)
end
Script.serveFunction('CSK_MultiColorSelection.addMaskingROI', addMaskingROI)

local function setMaskEditor(status)
  _G.logger:info(nameOfModule .. ": Set mask editor: " .. tostring(status))
  maskingROIEditorActive = status
  Script.notifyEvent("MultiColorSelection_OnMaskEditorActive", status)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'maskingROIEditorActive', status)
end
Script.serveFunction("CSK_MultiColorSelection.setMaskEditor", setMaskEditor)

local function setMaskingROIType(roiType)
  _G.logger:info(nameOfModule .. ": Set mask type: " .. tostring(roiType))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].type_maskingROI = roiType
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'setTypeMaskingROI', roiType)
end
Script.serveFunction('CSK_MultiColorSelection.setMaskingROIType', setMaskingROIType)

local function resetMask()
  _G.logger:info(nameOfModule .. ": Reset mask.")
  local amount = #multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject]["maskingROIs"]
  while amount >= 2 do
    table.remove(multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject]["maskingROIs"], amount)
    amount = amount - 1
  end
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'resetMask', true)
end
Script.serveFunction("CSK_MultiColorSelection.resetMask", resetMask)

local function setMaskingROIActive(status)
  _G.logger:info(nameOfModule .. ": Set 'maskingROIActive' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(status))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].maskingROIActive = status

  Script.notifyEvent("MultiColorSelection_OnNewStatusMaskActive", status)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'maskingROIActive', status, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setMaskingROIActive", setMaskingROIActive)

local function setMinGood(value)
  _G.logger:info(nameOfModule .. ": Set 'minGood' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(value))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].minGood = value

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'minGood', value, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setMinGood", setMinGood)

local function setMaxGood(value)
  _G.logger:info(nameOfModule .. ": Set 'maxGood' of colorObject no." .. tostring(selectedColorObject) .. " to " .. tostring(value))
  multiColorSelection_Instances[selectedInstance].parameters.colorObjects[selectedColorObject].maxGood = value

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'maxGood', value, selectedColorObject)
end
Script.serveFunction("CSK_MultiColorSelection.setMaxGood", setMaxGood)

local function setPipetteEditorActive(status)
  _G.logger:info(nameOfModule .. ": Set pipette editor: " .. tostring(status))
  pipetteActive = status
  Script.notifyEvent("MultiColorSelection_OnPipetteActive", status)
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'pipetteActive', status)
end
Script.serveFunction("CSK_MultiColorSelection.setPipetteEditorActive", setPipetteEditorActive)

local function setResultOutput(mode)
  _G.logger:info(nameOfModule .. ": Set 'resultOutput' to " .. mode)
  multiColorSelection_Instances[selectedInstance].parameters.resultOutput = mode

  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'resultOutput', mode)
end
Script.serveFunction("CSK_MultiColorSelection.setResultOutput", setResultOutput)

--- Function to react on incoming info of new image size of image provider
---@param event string Name of event
local function setNewImageSize(event)
  for i = 1, #multiColorSelection_Instances do
    if multiColorSelection_Instances[i].parameters.registeredEvent == event then
      Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', i, 'imageSize', '')
      return
    end
  end
end

--- Function to register on incoming info of new images size of image provider
---@param event string Name of event
local function registerOnImageSizeChange(event)
  if event ~= '' then
    if multiColorSelection_Instances[selectedInstance].parameters.registeredEvent ~= '' then
      local crownPos = string.find(multiColorSelection_Instances[selectedInstance].parameters.registeredEvent, '%.')
      local sendingCrown = string.sub(event, 1, crownPos-1)
      Script.deregister(sendingCrown .. ".OnNewImageSizeToShare", setNewImageSize)
    end
    local crownPos = string.find(event, '%.')
    if crownPos then
      local sendingCrown = string.sub(event, 1, crownPos-1)
      Script.register(sendingCrown .. ".OnNewImageSizeToShare", setNewImageSize)
    else
      _G.logger:warning(nameOfModule .. ": Not able to register to 'OnNewImageSizeToShare' event.")
    end
  end
end

local function setRegisterEvent(event)
  _G.logger:info(nameOfModule .. ": Set register event: " .. tostring(event))
  multiColorSelection_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
  registerOnImageSizeChange(event)
  Script.notifyEvent('MultiColorSelection_OnNewStatusRegisteredEvent', event)
end
Script.serveFunction("CSK_MultiColorSelection.setRegisterEvent", setRegisterEvent)

----------------------------------------------------------------------------------------

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  multiColorSelection_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiColorSelection.setParameterName", setParameterName)

local function sendParameters()
  if multiColorSelection_Instances[selectedInstance].persistentModuleAvailable then

    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiColorSelection_Instances[selectedInstance].parameters), multiColorSelection_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiColorSelection_Instances[selectedInstance].parametersName, multiColorSelection_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiColorSelection_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiColorSelection_Instances[selectedInstance].parametersName, multiColorSelection_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiColorSelection parameters with name '" .. multiColorSelection_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiColorSelection.sendParameters", sendParameters)

local function loadParameters()
  if multiColorSelection_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiColorSelection_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiColorSelectionInstance " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiColorSelection_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- Send config to instances
      local colorParams = helperFuncs.convertTable2Container(multiColorSelection_Instances[selectedInstance].parameters.colorObjects)
      Container.add(data, 'colorObjects', colorParams, 'OBJECT')
      Script.notifyEvent('MultiColorSelection_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
      registerOnImageSizeChange(multiColorSelection_Instances[selectedInstance].parameters.registeredEvent)
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiColorSelection:start()
end
Script.serveFunction("CSK_MultiColorSelection.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiColorSelection_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiColorSelection.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  -- Check if CSK_PersistentData version is > 1.x.x
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    for j = 1, #multiColorSelection_Instances do
      multiColorSelection_Instances[j].persistentModuleAvailable = false
    end
  else

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
      -- Check for amount if instances to create
      if totalInstances then
        local c = 2
        while c <= totalInstances do
          addInstance()
          c = c+1
        end
      end
    end


    for i = 1, #multiColorSelection_Instances do

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

      if parameterName then
        multiColorSelection_Instances[i].parametersName = parameterName
        multiColorSelection_Instances[i].parameterLoadOnReboot = loadOnReboot
      end

      if multiColorSelection_Instances[i].parameterLoadOnReboot then
        setInstance(i)
        loadParameters()
      end
    end
    Script.notifyEvent('MultiColorSelection_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

